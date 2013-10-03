<?php

namespace Puphpet\MainBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class FrontController extends Controller
{
    public function indexAction(Request $request)
    {
        if ($request->isMethod('POST')) {
            $manager = $this->get('puphpet.extension.manager');

            $manager->createArchive($request->request->all());
        }

        return $this->render('PuphpetMainBundle:front:index.html.twig', [
            'extensionManager' => $this->get('puphpet.extension.manager'),
        ]);
    }
}
