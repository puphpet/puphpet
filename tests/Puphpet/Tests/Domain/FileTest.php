<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Domain\File;

class FileTest extends \PHPUnit_Framework_TestCase
{
    protected $archivePathParent;
    protected $archivePath;
    protected $archiveFile;
    protected $filename;
    protected $filenameNoExtension;

    public function setUp()
    {
        parent::setUp();

        $this->filename = 'precise64.zip';
        $this->archivePathParent = '/tmp/51d1b3e0cd6adzgxi1K';
        $this->filenameNoExtension = 'precise64';
        $this->archivePath = $this->archivePathParent . '/' . $this->filenameNoExtension;
        $this->archiveFile = $this->archivePathParent . '.zip';
    }

    /**
     * @param int $cleanUpOffset
     *
     * @return \PHPUnit_Framework_MockObject_MockObject
     */
    protected function getFilesystemMock($cleanUpOffset = 3)
    {
        $mock = $this->getMockBuilder('\Puphpet\Domain\Filesystem')
            ->disableOriginalConstructor()
            ->setMethods(
                [
                    'getSysTempDir',
                    'getTmpFolder',
                    'exec',
                    'putContents',
                    'mirror',
                    'createArchive',
                    'remove',
                    'createFolder',
                    'clearTmpDirectory'
                ]
            )
            ->getMock();

        // called at the beginning within setPaths
        $mock->expects($this->at(0))
            ->method('getTmpFolder')
            ->will($this->returnValue($this->archivePathParent));

        $mock->expects($this->at(1))
            ->method('createFolder')
            ->with($this->archivePath)
            ->will($this->returnValue(true));

        // start: setPaths (3 calls)
        // called at the very end
        $mock->expects($this->once())
            ->method('createArchive')
            ->with($this->archiveFile);



        // no expectation on "mirror" method here
        // as assertions on this method differ from test to test
        return $mock;
    }

    public function testCreateArchiveDoesNotCallCopyFileOnNoReplacementFilesIdentified()
    {
        $filesystem = $this->getFilesystemMock();

        $filesystem->expects($this->never())
            ->method('putContents');

        $replacementFiles = array();

        $file = new File($filesystem);
        $file->setName($this->filename);
        $file->createArchive($replacementFiles);
        $createdFile = $file->getArchiveFile();

        $this->assertEquals(
            $this->archiveFile,
            $createdFile
        );
    }

    public function testCreateArchiveCallsCopyFile()
    {
        // setPaths: 2 filesystem calls
        // copyToTempFolder (createFolder): 1 filesystem call
        // cleanUpOffset => 3 (starting by 0)
        $filesystem = $this->getFilesystemMock();

        $replacementFiles = [
            'replacement1' => 'foobar',
            'replacement2' => 'foobaz',
            'replacement3' => 'bambam',
        ];

        $filesystem->expects($this->at(2))
            ->method('createFolder');

        // cleanupFiles: 2 filesystem calls + 4 offset
        // => copyFile(putContents) starts at index 3 (starting by 0)
        $filesystem->expects($this->at(3))
            ->method('putContents')
            ->with($this->archivePath . '/replacement1', 'foobar');

        $filesystem->expects($this->at(4))
            ->method('putContents')
            ->with($this->archivePath . '/replacement2', 'foobaz');

        $filesystem->expects($this->at(5))
            ->method('putContents')
            ->with($this->archivePath . '/replacement3', 'bambam');

        $file = new File($filesystem);
        $file->setName($this->filename);
        $file->createArchive($replacementFiles);
        $createdFile = $file->getArchiveFile();

        $this->assertEquals(
            $this->archiveFile,
            $createdFile
        );
    }

    public function testCreateArchiveIncludesOptionalModulesOnRequest()
    {
        $moduleName1   = 'awesomeModule';
        $moduleSource1 = 'path/to/source';

        $moduleName2   = 'awesomeModule2';
        $moduleSource2 = 'path/to/source2';

        $replacementFiles = ['foo' => 'bar'];

        $filesystem = $this->getFilesystemMock(5);

        // 2nd createFolder is done within "copyToTempFolder" method
        // and before cleanupFiles is called
        $filesystem->expects($this->at(2))
            ->method('createFolder')
            ->with($this->archivePath . '/modules');

        $filesystem->expects($this->at(3))
            ->method('mirror')
            ->with($moduleSource1, $this->archivePath . '/modules/' . $moduleName1);

        $filesystem->expects($this->at(4))
            ->method('mirror')
            ->with($moduleSource2, $this->archivePath . '/modules/' . $moduleName2);

        // this is called after mirroring and cleanupFiles
        $filesystem->expects($this->at(5))
            ->method('putContents')
            ->with($this->archivePath . '/foo', 'bar');

        $filesystem->expects($this->once())
            ->method('clearTmpDirectory')
            ->with($this->archivePathParent);

        $file = new File($filesystem);
        $file->setName($this->filename);
        $file->addModuleSource($moduleName1, $moduleSource1);
        $file->addModuleSource($moduleName2, $moduleSource2);
        $file->createArchive($replacementFiles);
        $createdFile = $file->getArchiveFile();

        $this->assertEquals(
            $this->archiveFile,
            $createdFile
        );
    }

    public function testCreateArchiveIncludesOnlyOneModuleByUniqueName()
    {
        $moduleName   = 'awesomeModule';
        $moduleSource = 'path/to/source';

        $moduleSource2 = 'path/to/source2';

        $replacementFiles = ['foo' => 'bar'];

        $filesystem = $this->getFilesystemMock(4);

        // 2nd createFolder is done within "copyToTempFolder" method
        $filesystem->expects($this->at(2))
            ->method('createFolder')
            ->with($this->archivePath . '/modules');

        // second call with the same module will overwrite the requestes module source
        $filesystem->expects($this->at(3))
            ->method('mirror')
            ->with($moduleSource2, $this->archivePath . '/modules/' . $moduleName);

        $filesystem->expects($this->at(4))
            ->method('putContents')
            ->with($this->archivePath . '/foo', 'bar');

        $filesystem->expects($this->once())
            ->method('clearTmpDirectory')
            ->with($this->archivePathParent);

        $file = new File($filesystem);
        $file->setName($this->filename);
        $file->addModuleSource($moduleName, $moduleSource);
        $file->addModuleSource($moduleName, $moduleSource2);
        $file->createArchive($replacementFiles);
        $createdFile = $file->getArchiveFile();

        $this->assertEquals($this->archiveFile, $createdFile);
    }
}
