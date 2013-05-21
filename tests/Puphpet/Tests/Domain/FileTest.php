<?php

namespace Puphpet\Tests\Domain;

use Puphpet\Domain\File;
use Puphpet\Tests\Base;

class FileTest extends Base
{
    protected $source;
    protected $sysTempDir;
    protected $tmpFolder;
    protected $tmpPath;
    protected $archiveFile;

    public function setUp()
    {
        parent::setUp();

        $this->source = '/my/source/folder';
        $this->sysTempDir = '/tmp';
        $this->tmpFolder = '123abc';
        $this->tmpPath = "{$this->sysTempDir}/{$this->tmpFolder}";
        $this->archiveFile = "{$this->sysTempDir}/{$this->tmpFolder}/tmpFile";
    }

    /**
     * @param string $constructorArgs Constructor arguments
     *
     * @return \PHPUnit_Framework_MockObject_MockObject
     */
    protected function getFilesystemMock()
    {

        $mock = $this->getMockBuilder('\Puphpet\Domain\Filesystem')
          ->disableOriginalConstructor()
          ->setMethods(
              [
                  'getSysTempDir',
                  'getTmpFolder',
                  'getTmpFile',
                  'exec',
                  'putContents',
                  'mirror',
                  'createArchive',
              ]
          )
          ->getMock();

        $mock->expects($this->once())
          ->method('getSysTempDir')
          ->will($this->returnValue($this->sysTempDir));

        $mock->expects($this->once())
          ->method('getTmpFolder')
          ->will($this->returnValue($this->tmpFolder));

        $mock->expects($this->once())
          ->method('getTmpFile')
          ->with($this->sysTempDir, $this->tmpFolder)
          ->will($this->returnValue($this->archiveFile));

        $mock->expects($this->once())
          ->method('createArchive')
          ->with($this->archiveFile . '.zip');

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

        $file = new File($this->source, $filesystem);
        $file->createArchive($replacementFiles);
        $createdFile = $file->getArchivePath();

        $this->assertEquals(
            "{$this->archiveFile}.zip",
            $createdFile
        );
    }

    public function testCreateArchiveCallsCopyFile()
    {
        $filesystem = $this->getFilesystemMock();

        $replacementFiles = [
            'replacement1' => 'foobar',
            'replacement2' => 'foobaz',
            'replacement3' => 'bambam',
        ];

        // setPaths: 3 filesystem calls
        // copyToTempFolder: 1 filesystem call
        // => copyFile(putContents) starts at index 4 (starting by 0)
        $filesystem->expects($this->at(4))
          ->method('putContents')
          ->with($this->tmpPath . '/replacement1', 'foobar');

        $filesystem->expects($this->at(5))
          ->method('putContents')
          ->with($this->tmpPath . '/replacement2', 'foobaz');

        $filesystem->expects($this->at(6))
          ->method('putContents')
          ->with($this->tmpPath . '/replacement3', 'bambam');

        $file = new File($this->source, $filesystem);
        $file->createArchive($replacementFiles);
        $createdFile = $file->getArchivePath();

        $this->assertEquals(
            "{$this->archiveFile}.zip",
            $createdFile
        );
    }

    public function testCreateArchiveIncludesOptionalModulesOnRequest()
    {
        $moduleName1 = 'awesomeModule';
        $moduleSource1 = 'path/to/source';

        $moduleName2 = 'awesomeModule2';
        $moduleSource2 = 'path/to/source2';

        $replacementFiles = ['foo' => 'bar'];

        $filesystem = $this->getFilesystemMock();

        // mirroring is done within "copyToTempFolder" method
        $filesystem->expects($this->at(3))
          ->method('mirror')
          ->with($this->source, $this->tmpPath);

        $filesystem->expects($this->at(4))
          ->method('mirror')
          ->with($moduleSource1, $this->tmpPath . '/modules/' . $moduleName1);

        $filesystem->expects($this->at(5))
          ->method('mirror')
          ->with($moduleSource2, $this->tmpPath . '/modules/' . $moduleName2);

        $filesystem->expects($this->at(6))
          ->method('putContents')
          ->with($this->tmpPath . '/foo', 'bar');

        $file = new File($this->source, $filesystem);
        $file->addModuleSource($moduleName1, $moduleSource1);
        $file->addModuleSource($moduleName2, $moduleSource2);
        $file->createArchive($replacementFiles);
        $createdFile = $file->getArchivePath();

        $this->assertEquals($this->archiveFile . '.zip', $createdFile);
    }

    public function testCreateArchiveIncludesOnlyOneModuleByUniqueName()
    {
        $moduleName = 'awesomeModule';
        $moduleSource = 'path/to/source';

        $moduleSource2 = 'path/to/source2';

        $replacementFiles = ['foo' => 'bar'];

        $filesystem = $this->getFilesystemMock();

        // mirroring is done within "copyToTempFolder" method
        $filesystem->expects($this->at(3))
          ->method('mirror')
          ->with($this->source, $this->tmpPath);

        // second call with the same module will overwrite the requestes module source
        $filesystem->expects($this->at(4))
          ->method('mirror')
          ->with($moduleSource2, $this->tmpPath . '/modules/' . $moduleName);

        $filesystem->expects($this->at(5))
          ->method('putContents')
          ->with($this->tmpPath . '/foo', 'bar');

        $file = new File($this->source, $filesystem);
        $file->addModuleSource($moduleName, $moduleSource);
        $file->addModuleSource($moduleName, $moduleSource2);
        $file->createArchive($replacementFiles);
        $createdFile = $file->getArchivePath();

        $this->assertEquals($this->archiveFile . '.zip', $createdFile);
    }
}
