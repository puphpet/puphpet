<?php

namespace Puphpet\MainBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class DefaultController extends Controller
{
    public function indexAction(Request $request)
    {
        if ($request->isMethod('POST')) {
            $manager = $this->get('puphpet.extension.manager');
            $submittedExtensions = $manager->matchExtensionToArrayValues(
                $request->request->all()
            );

            $extensions = [];
            foreach ($submittedExtensions as $slug => $data) {
                $extension = $manager->getExtensionBySlug($slug);
                $extension->setCustomData($data);

                $extensions[$slug] = $extension;
            }

            if (!empty($extensions['vagrantfile'])) {
                /** @var Extension\ExtensionInterface $vagrantfile */
                $vagrantfile = $extensions['vagrantfile'];
                $foo = $vagrantfile->getData();
                ini_set('html_errors', 0);
                echo '<pre>';
                xdebug_var_dump($vagrantfile->renderManifest($vagrantfile->getData()));
                exit;
            }
        }

        return $this->render('PuphpetMainBundle:Default:index.html.twig', [
            'extensionManager' => $this->get('puphpet.extension.manager'),
        ]);
    }
}
