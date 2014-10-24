--- 
layout: post
author: Rob
title: SLS Services | Overview
published: true
---

<div style="display:inline-block; max-width:50%; float:left">
  <a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_cover.jpg"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_cover.jpg"></a>
</div>
<div style="display:inline-block; max-width:50%; float:left">
  <a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_cover_back.jpg"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_cover_back.jpg"></a>
</div>
<div class="footer" align="bottom">(Left) Front view of "Collar 2," an original necklace design by <a href="https://www.flickr.com/photos/53730604@N06/12076178515/in/photolist-jp8z9p-eWvTQf-26pkpw-dwzeKj-2jfZaw-jpaBN7-dwzg5G-4qrWTc-aRzfAD-ejcnvR-boThZW-9HZMiW-7fCpB3-d6quSy-bfJA1a-2mv2ij-dwtJDk-bA3QmZ-3HUyDd-j7TLHm-j7TRPy-ccBX83-j7PxuV-3KtQcJ-e6jUQ7-4qhNAY-8CZN4b-hVZX2M-eJQCXi-d6qrLN-d6qs79-d6qzNS-d6qAWy-d6qdF7-d6qrm7-eajiyj-n2oDE-P5iYB-7PTr8M-4JyRQA-3Hf6M3-5iZpB4-nfR49F-6mFeJw-4y8FLP-anKaYf-o1Tmry-cGWnBL-irD87Q-n2huR6" target="_blank">Madeline Gannon</a> printed with SLS. (Right) <a href="https://www.flickr.com/photos/53730604@N06/12076178275/in/photolist-jp8z5g-3HaURx-jp8z9p-eWvTQf-26pkpw-dwzeKj-2jfZaw-jpaBN7-dwzg5G-4qrWTc-aRzfAD-ejcnvR-boThZW-9HZMiW-7fCpB3-d6quSy-bfJA1a-2mv2ij-dwtJDk-bA3QmZ-3HUyDd-j7TLHm-j7TRPy-ccBX83-j7PxuV-3KtQcJ-e6jUQ7-4qhNAY-8CZN4b-hVZX2M-eJQCXi-d6qrLN-d6qs79-d6qzNS-d6qAWy-d6qdF7-d6qrm7-eajiyj-n2oDE-P5iYB-7PTr8M-4JyRQA-3Hf6M3-5iZpB4-nfR49F-6mFeJw-4y8FLP-anKaYf-o1Tmry-cGWnBL" target="_blank">Reverse view</a> of the same piece. Used under <a href="https://creativecommons.org/licenses/by-nc/2.0/legalcode" target="_blank">CC BY-NC 2.0.</a></div>

<br>
<p>This post is intended for people who are new to 3D printing and want to learn more about one of the more common methods used today, Selective Laser Sintering (SLS). SupplyBetter has helped people with SLS services intended for both prototype and production use cases. While there are <a href="http://www.shapeways.com/materials/strong-and-flexible-plastic?li=nav" target="_blank">great resources</a> out there already with design tips, we want to help the curious buyer determine whether or not this is a 3D printing process that is right for them.</p>

<h3>What is SLS?</h3>
<p>SLS is an additive manufacturing method that produces solid parts from a variety of powders, using a laser as an energy source. First, specialized software slices a CAD design into individual, planar, cross-sections. The SLS machine then rolls out a thin layer of powder onto the build table, and a laser traces the first cross-section of the object in the powder. This causes the affected powder particles to bond (or 'sinter', hence the name) together into a solid slice of plastic. The build table is then moved down slightly, another layer of powder is rolled out on top of the old, and the laser traces the design for the next cross-section. Each time a new layer is made, it is also fused to the layer below, forming a solid object. In this way, a part is built from the bottom up, with any overhangs supported by the un-sintered powder. After the part is completed, the excess powder must be removed by hand.</p>

<h3>Is SLS right for me?</h3>
<p>Let's start with an example. Take this part, for instance, and let's say you need 25 of them in your hands in a week.</p>


<div style="display:inline-block; max-width:100%; float:left">
  <a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_services_3.jpg" target="_blank"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_services_3.jpg"></a>
</div>
<div class="footer" align="bottom">Custom, functional bracket produced with SLS</div>

<p>This is an ideal use case for SLS 3D printing, and is actually from a real project that came through SupplyBetter: 
  <ul>
    <li>Unique geometry (it is indeed a custom part).</li>
    <li>Complex geometry. This makes it impractical to make this part using other manufacturing methods, like injection molding, without huge upfront cost.</li>
    <li>Small outer dimensions and features.</li>
    <li>A "living hinge." (<a href="http://en.wikipedia.org/wiki/Living_hinge" target="_blank">What's a living hinge?</a>)</li>
  </ul>
</p>
<br>

<h3>What SLS is great for</h3>
<ul>
  <li>Having the least amount of design considerations: You can print almost anything without having to worry about support material or overhangs.</li>
  <li>Producing a consistent matte surface finish: Parts generally look pretty great.</li>
  <li>When you need relatively isotropic tolerances or mechanical behavior: Isotropic means <a href="http://en.wikipedia.org/wiki/Isotropy#Materials_science" target="_blank">directionally independent mechanical properties</a>. Unlike <a href="https://www.supplybetter.com/blog/what-to-expect-with-fdm.thml" target="_blank">FDM</a> parts, which have much lower tensile strengths in the "z" direction, SLS parts have only slightly different mechanical properties for different build orientations.</li>
  <li>Small features: See the images below for the kind of quality you can expect when your design has small features present. </li>
  <li>Flexibility: See videos at the bottom of the page for examples.</li>
</ul>

<h3>What SLS is not great for</h3>
<ul> 
  <li>Color: SLS parts are monochromatic, with color choices typically limited to just black and white.</li>
  <li>Post-processing options: If you want an automotive-grade or  injection molded quality surface finish (i.e. glossy and smooth), then SLS is not a good fit. Parts will need to be sanded before being painted, and SLS doesn't do well with both sanding and painting (parts have a tendency to absorb paint). Parts can be dyed, but be sure to find a supplier who has experience dyeing parts to make sure you're going to get a uniform surface finish. </li>
  <li>Same day speeds: build chambers take a relatively long time to heat up and cool down (vs. SLA or polyjet which are 3D printing processes that do not rely on a heated build chamber in order to 3D print material). While 1 day lead times are actually quite common with SLS, same day is rare. In SLS's defense though, same-day 3D printing is currently generally only achievable via FDM printing of parts that do not require support material.</li>
  <li>Hollow parts: If your part has a void space, then that space will contain trapped, unsintered powder. If this happens, your part will be heavier than expected, as well as more expensive (since you will be charged for the trapped material used).</li>
</ul>


<div style="display:inline-block; max-width:100%; float:left">
  <a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_services_1.jpg" target="_blank"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_services_1.jpg"></a>
</div>
<div class="footer" align="bottom">SLS nylon 3D print of a clothes pin courtesy of <a href="https://www.supplybetter.com/suppliers/unitedstates/all/sculpteo" target="_blank">Sculpteo</a></div>

<div style="display:inline-block; max-width:100%; float:left">
  <a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_services_2.jpg" target="_blank"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/sls_services_2.jpg"></a>
</div>
<div class="footer" align="bottom">SLS nylon 3D print of a customized bracelet courtesy of <a href="http://www.shapeways.com/madewithcode" target="_blank">Made With Code</a></div>

<h3>Materials</h3>
<p> Nylon is by far the most common material used in Selective Laser Sintering. Nylon 12, PA2200, and Duraform PA are different technical terms for basically the same material, they are just just specific brands of material favored by the manufacturers of the machine. Here's short list of materials and datasheets so you can look for yourself.</p>
<h4>Common SLS 3D printing materials</h4>
<ul>
  <li>Nylon 12 (white): <a href="http://www.3dsystems.com/sites/www.3dsystems.com/files/DS_DuraForm_PA_US.pdf" target="_blank">datasheet</a></li>
  <li>PA2200 (white): <a href="https://www.solidconcepts.com/content/pdfs/material-specifications/sls-nylon-12-pa.pdf" target="_blank">datasheet</a></li>
  <li>Duraform PA (white): <a href="https://www.shapeways.com/rrstatic/material_docs/mds-strongflex.pdf" target="_blank">datasheet</a></li>
</ul>
<h4>Less common SLS 3D printing materials</h4>
<ul>
  <li>Nylon 12  - glass filled (white): <a href="https://www.solidconcepts.com/content/pdfs/material-specifications/sls-nylon-12-gf.pdf" target="_blank">datasheet</a></li>
  <li>Duraform EX (black): <a href="http://www.paramountind.com/pdfs/PI_DS_DuraForm_EX_US.pdf" target="_blank">datasheet</a></li>
  <li>Elasto-Plastic (yellow): <a href="https://www.shapeways.com/materials/elasto-plastic?li=nav" target="_blank">datasheet</a></li>
</ul>

<p><i>But why not just go to <a href="https://www.supplybetter.com/blog/shapeways-vs-supplybetter.html" target="_blank">Shapeways</a>?</i></p>
<p>Shapeways is great for low cost, non-critical parts that don't have a short deadline. If a job is fit for Shapeways (or any of the other online service bureaus), then we'll definitely recommend them, but for jobs that require any degree of speed and quality, finding an SLS service bureau is the right choice.</p>

<p>Finally, to give you an idea of how durable SLS nylon prints are, we put together a few videos to illustrating the mechanical properties of a few parts we had around the office. Enjoy!</p>

<p>Cheers,</p>
<p>Rob</p>


<iframe src="https://gfycat.com/ifr/FittingSlushyAmazonparrot" frameborder="0" scrolling="no" width="940" height="529" style="-webkit-backface-visibility: hidden;-webkit-transform: scale(1);" ></iframe>
<div class="footer" align="bottom">The same SLS nylon 3D print of the clothes pin from earlier in the post</div>

<iframe src="https://gfycat.com/ifr/QuarterlyJitteryAmericanwigeon" frameborder="0" scrolling="no" width="940" height="529" style="-webkit-backface-visibility: hidden;-webkit-transform: scale(1);" ></iframe>
<div class="footer" align="bottom">SLS nylon 3D print of a custom bracket printed by <a href="https://www.supplybetter.com/suppliers/unitedstates/newyork/finnovation" target="_blank">Finnovation PD</a></div>

<iframe src="https://gfycat.com/ifr/SecondhandImpeccableCardinal" frameborder="0" scrolling="no" width="940" height="529" style="-webkit-backface-visibility: hidden;-webkit-transform: scale(1);" ></iframe>
<div class="footer" align="bottom">Destructively testing the same SLS nylon 3D print</div>

