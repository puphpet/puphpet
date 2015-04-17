<?php

namespace Puphpet\MainBundle\Controller;

use Puphpet\MainBundle\Extension;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Yaml\Yaml;

class FrontController extends Controller
{
    public function indexAction(Request $request)
    {
        $manager = $this->get('puphpet.extension.manager');

        if ($request->isMethod('POST')) {
            $archive = $manager->createArchive($request->request->all());

            $response = new Response;
            $response->headers->set('Content-type', 'application/octet-stream');
            $response->headers->set('Content-Disposition', 'attachment; filename="puphpet.zip"');
            $response->setContent(file_get_contents($archive));

            return $response;
        }

        return $this->render('PuphpetMainBundle:front:template.html.twig', [
            'extensions' => $manager->getExtensions(),
        ]);
    }

    public function uploadConfigAction(Request $request)
    {
        $config = $this->normalizeLineBreaks($request->get('config'));

        try {
            $yaml = Yaml::parse($config);
        } catch (\Exception $e) {}

        if (empty($yaml)) {
            $this->get('session')->getFlashBag()->add(
                'error',
                'The config file provided was empty! Please recreate your manifest manually below.'
            );

            return new RedirectResponse($this->generateUrl('puphpet.main.homepage'));
        }

        $manager = $this->get('puphpet.extension.manager');
        $manager->setCustomDataAll($yaml);

        try {
            $foo = $manager->getExtensions();

            $rendered = $this->render('PuphpetMainBundle:front:index.html.twig', [
                'extensions' => $manager->getExtensions(),
            ]);

            return $rendered;
        } catch (\Exception $e) {
            $this->get('session')->getFlashBag()->add(
                'error',
                'The config file provided had errors! Please recreate your manifest manually below.'
            );

            return new RedirectResponse($this->generateUrl('puphpet.main.homepage'));
        }
    }

    public function generateArchiveAction(Request $request)
    {
        $config = $this->normalizeLineBreaks($request->get('config'));

        $values = '';

        try {
            $values = Yaml::parse($config);
        } catch (\Exception $e) {}

        if (empty($values)) {
            $response = new Response;
            $response->setStatusCode(Response::HTTP_NOT_ACCEPTABLE);

            return $response;
        }

        $manager = $this->get('puphpet.extension.manager');
        $archive = $manager->createArchive($values);

        $response = new Response;
        $response->headers->set('Content-type', 'application/octet-stream');
        $response->headers->set('Content-Disposition', sprintf('attachment; filename="%s"', 'puphpet.zip'));
        $response->setContent(file_get_contents($archive));

        return $response;
    }

    public function aboutAction()
    {
        return $this->render('PuphpetMainBundle:front:about.html.twig');
    }

    public function helpAction()
    {
        return $this->render('PuphpetMainBundle:front:help.html.twig');
    }

    public function githubBtnAction()
    {
        if ($this->container->has('profiler')) {
            $this->container->get('profiler')->disable();
        }

        return $this->render('PuphpetMainBundle:front:github-btn.html.twig');
    }

    /**
     * Normalize linebreaks user-submitted text.
     *
     * @param string $config
     * @return string
     */
    private function normalizeLineBreaks($config)
    {
        $config = str_replace("\r\n", "\n", $config);
        $config = str_replace("\n\r", "\n", $config);

        $config = str_replace('\r\n', '\n', $config);
        $config = str_replace('\n\r', '\n', $config);

        return $config;
    }
}
