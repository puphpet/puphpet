<?php

namespace Puphpet\MainBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class FrontController extends Controller
{
    public function indexAction(Request $request)
    {
        if ($request->isMethod('POST')) {
            $manager = $this->get('puphpet.extension.manager');

            $archive = $manager->createArchive($request->request->all());

            $response = new Response;
            $response->headers->set('Content-type', 'application/octet-stream');
            $response->headers->set('Content-Disposition', sprintf('attachment; filename="%s"', 'puphpet.zip'));
            $response->setContent(file_get_contents($archive));

            return $response;
        }

        return $this->render('PuphpetMainBundle:front:index.html.twig', [
            'extensionManager' => $this->get('puphpet.extension.manager'),
        ]);
    }
}
