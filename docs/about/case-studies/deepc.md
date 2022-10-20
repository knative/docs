---
hide:
  - toc
---
<h1 style="color:#0071c7;font-size: 3em;">deepc Case Study</h1>
<table style="border: 0;">
<tr style="background-color: var(--md-default-bg-color);">
<td style="border: 0;">
<div style="min-width: 20mm;">
      <img src="../../../images/case-studies/deepc.png" alt="" draggable="false" />
</div>
<div>
<em style="color:#0071c7;font-size: 1em;">“It should be possible for somebody with an algorithm to have it on the platform in an hour”</em>
</div>
<div>
<p style="color:#0071c7;font-size: 1em;">-- Andrew Webber, Senior Software Engineer for deepc</p>
</div>

</td>

<td style="border: 0;">
<h2 style="font-weight: bold;">AI Startup deepc Connects Researchers to Radiologists with Knative Eventing</h2>

deepc is a startup at the cutting edge, bringing advanced data techniques and artificial intelligence to healthcare. The German company helps radiologists  access better diagnostics and resources through cloud-based technology. Their goal is to elevate treatment  quality across the board while creating more efficiency and improvement in medical settings.
This revolution in technology comes with hefty challenges. Care systems are highly regulated, making patient privacy and safety a top priority for deepc. Doctors and medical staff also demand that new technologies be reliable and stable when lives are on the line.



<h2 style="color:#0071c7;">Rising to the challenge</h2>

deepc has risen to meet these challenges through carefully architected solutions, using tools like Knative Eventing to their full potential. Their product helps radiologists access a wide selection of artificial intelligence (AI) programs that analyze imaging, like x-rays and MRIs. The data generated from these AI programs help radiologists make more accurate diagnoses.

<h2 style="color:#0071c7;">The deepc workflow</h2>

The radiologist uploads the image into deepcOS, initially to a virtual machine within the hospital IT infrastructure containing the deepcOS client application. After making a series of selections, deepcOS identifies the proper AI to use. It then removes the patient information from the scans before encrypting the data.
deepcOS sends that data to the cloud-based deepc AI platform. This platform does the heavy lifting in providing the computing power the AI algorithms need to do their work. After the program finishes, the results are sent back. Finally, the data is reassociated with the patient, and the radiologist can take action based on the results. Critically, patient information always remains on-premises in the hospital and is not transmitted to deepc servers.

<h2 style="color:#0071c7;">A Knative-powered process</h2>

The deepcOS workflow builds on a sophisticated implementation of Knative Eventing. Knative Eventing allows teams to deploy event-driven architecture with serverless applications quickly. In conjunction with Knative Serving, deepc resources and programs scale up and down automatically based on specific event triggers laid out by the developers. Knative takes care of the management, so the process does not need to wait for a person to take action.
When data is sent to deepc's cloud-based platform, Knative emits an event that triggers a specific AI. After one is selected, Knative starts a container environment for the program to run. Some AI programs may only need one container. Others may require multiple, running parallel or in sequence. In the case of multiple containers, the deepc team created workflows using Knative Eventing to coordinate the complex processes. After the process finishes and provides the output for the radiologist, Knative triggers stop the active containers.

<h2 style="color:#0071c7;"><em>"Knative gives us a foundation of consistency,"</em> said Andrew Webber, Senior Software Engineer.</h2>

<h2 style="color:#0071c7;">Bridging between legacy and advanced systems</h2>

The platform makes available AIs developed by leading global companies and researchers. Knative has also allowed integration with the work of independent researchers through an SDK implementation for radiologists. They don’t need to be Kubernetes experts or take days to bring their work to patients through deepc’s platform.

<h2 style="color:#0071c7;"><em>“It should be possible for somebody with an algorithm to have it on the platform in an hour”</em> said Webber.</h2>

Some implementations are more complex. They use legacy technology that does not fit into a standard container or they have unique architectures that require OS-level configuration. deepc has built out APIs and virtual machines that connect those technologies to their own cloud-based platform and still integrate with the Knative Eventing workflow. This approach ensures those programs work flawlessly within the system.

<h2 style="color:#0071c7;">The case for business</h2>

The choice to develop their platform around Knative has had several business benefits for the startup. One of the most complicated aspects of growing a company is scaling. Many technology companies find their developers start scrambling when more customers are onboarded, uncovering new bugs and other issues. However, because of the nature of Knative, this is less of a problem for deepc. Knative's combination of automation and serverless methods means as more customers are onboarded, deepc will not need to build out more resources - it will all happen automatically.
Knative has also allowed the startup to add real value to customers using their technology. For example, because many applications used by radiologists are built by different companies, medical professionals have had to interact with disparate systems and procedures. deepc provides access to the work of many researchers on one platform, ending complicated processes for professionals on the ground. Healthcare systems get simple, unified billing. Knative has helped deepc create a robust case for customers to use their platform.

<h2 style="color:#0071c7;">Looking forward</h2>

deepc has already done amazing things as a company, with many more features planned. The company is a model for how Knative can help any organization build an impressive technical architecture capable of addressing some of today's most complex problems. Using features provided by Knative has enabled them to pioneer what is possible.

<h2 style="color:#0071c7;">Find out more</h2>

<ul>
<li><a href="../../../getting-started/">Getting started with Knative</a></li>
<li><a href="../../../serving/">Knative Serving</a></li>
<li><a href="../../../eventing/">Knative Eventing</a></li>
</ul>

    </td>
  </tr>
</table>
