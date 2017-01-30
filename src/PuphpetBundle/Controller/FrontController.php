<?php

namespace PuphpetBundle\Controller;

use PuphpetBundle\Controller;
use PuphpetBundle\Helper;

use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;

use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Yaml\Yaml;

class FrontController extends Controller
{
    /**
     * @param Request $request
     * @return Response
     * @Route("/",
     *     name="puphpet.main.homepage")
     * @Method({"GET"})
     */
    public function indexAction(Request $request)
    {
        $manager = $this->get('puphpet.extension.manager');

        $session = $this->getSession();

        $messages = $session->getFlashBag()->all();

        return $this->render('PuphpetBundle:front:template.html.twig', [
            'extensions' => $manager->getExtensions(),
            'messages'   => $messages,
        ]);
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/",
     *     name="puphpet.main.homepage.post")
     * @Method({"POST"})
     */
    public function postIndexAction(Request $request)
    {
        $manager = $this->get('puphpet.extension.manager');

        $archive = $manager->createArchive($request->request->all());

        $response = new Response;
        $response->headers->set('Content-type', 'application/octet-stream');
        $response->headers->set('Content-Disposition', 'attachment; filename="puphpet.zip"');
        $response->setContent(file_get_contents($archive));

        return $response;
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/upload-config",
     *     name="puphpet.main.upload_config")
     * @Method({"POST"})
     */
    public function postUploadConfigAction(Request $request)
    {
        $config = Helper\DataTransform::normalizeLineBreaks($request->get('config'));

        $session = $this->getSession();

        $yaml = new Yaml();

        try {
            $parsed = $yaml::parse($config);
        } catch (\Exception $e) {
            $session->getFlashBag()->add('error', [
                'title'   => 'There was a problem parsing your config file',
                'content' => $e->getMessage(),
            ]);

            $request->setMethod('GET');

            return $this->indexAction($request);
        }

        if (empty($parsed)) {
            $session->getFlashBag()->add('error', [
                'title'   => 'The config file provided was empty',
                'content' => 'Check your config file, or manually recreate it in the GUI.',
            ]);

            $request->setMethod('GET');

            return $this->indexAction($request);
        }

        $manager = $this->get('puphpet.extension.manager');
        $manager->setCustomDataAll($parsed);

        try {
            $session->getFlashBag()->add('success', [
                'title'   => 'Success!',
                'content' => 'Your previously generated config file was successfully loaded!',
            ]);

            $rendered = $this->render('PuphpetBundle:front:template.html.twig', [
                'extensions' => $manager->getExtensions(),
                'messages'   => $session->getFlashBag()->all(),
            ]);

            return $rendered;
        } catch (\Exception $e) {
            $session->getFlashBag()->clear();

            $session->getFlashBag()->add('error', [
                'title'   => 'There was a problem parsing your config file',
                'content' => sprintf(
                    '<p>Please recreate your manifest manually below.</p>' .
                    '<p>Error message:</p><p>%s</p>', $e->getMessage()
                )
            ]);

            return new RedirectResponse($this->generateUrl('puphpet.main.homepage'));
        }
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/generate-archive",
     *     name="puphpet.main.generate_archive")
     * @Method({"POST"})
     */
    public function postGenerateArchiveAction(Request $request)
    {
        $config = Helper\DataTransform::normalizeLineBreaks($request->get('config'));

        $yaml = new Yaml();

        try {
            $parsed = $yaml::parse($config);
        } catch (\Exception $e) {}

        if (empty($parsed)) {
            $response = new Response;
            $response->setStatusCode(Response::HTTP_NOT_ACCEPTABLE);

            return $response;
        }

        $manager = $this->get('puphpet.extension.manager');
        $archive = $manager->createArchive($parsed);

        $response = new Response;
        $response->headers->set('Content-type', 'application/octet-stream');
        $response->headers->set('Content-Disposition', sprintf('attachment; filename="%s"', 'puphpet.zip'));
        $response->setContent(file_get_contents($archive));

        return $response;
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/generate-config",
     *     name="puphpet.main.generate_config")
     * @Method({"POST"})
     */
    public function generateConfigAction(Request $request)
    {
        $manager = $this->get('puphpet.extension.manager');
        $yaml    = new Yaml();

        try {
            $config  = $manager->createConfig($request->request->all());
        } catch (\Exception $e) {}

        if (empty($config)) {
            $response = new Response;
            $response->setStatusCode(Response::HTTP_NOT_ACCEPTABLE);

            return $response;
        }

        $response = new Response;
        $response->headers->set('Content-type', 'text/html');
        $response->setContent('<pre>' . $yaml->dump($config, 50, 4));

        return $response;
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/download-puppet-modules",
     *     name="puphpet.main.download_puppet_modules")
     * @Method({"GET"})
     */
    public function downloadPuppetModulesAction(Request $request)
    {
        $manager = $this->get('puphpet.extension.manager');
        $archive = $manager->getPuppetModules();

        $response = new Response;
        $response->headers->set('Content-type', 'application/octet-stream');
        $response->headers->set('Content-Disposition', sprintf('attachment; filename="%s"', 'puphpet.zip'));
        $response->setContent(file_get_contents($archive));

        return $response;
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/about",
     *     name="puphpet.main.about")
     * @Method({"GET"})
     */
    public function aboutAction(Request $request)
    {
        return $this->redirect('/#about');
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/help",
     *     name="puphpet.main.help")
     * @Method({"GET"})
     */
    public function helpAction(Request $request)
    {
        return $this->redirect('/#help');
    }

    /**
     * @param Request $request
     * @return Response
     * @Route("/github-btn",
     *     name="puphpet.main.github_btn")
     * @Method({"GET"})
     */
    public function githubBtnAction(Request $request)
    {
        if ($this->container->has('profiler')) {
            $this->container->get('profiler')->disable();
        }

        return $this->render('PuphpetBundle:front:github-btn.html.twig');
    }
}
