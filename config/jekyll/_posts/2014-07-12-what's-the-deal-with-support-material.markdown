--- 
layout: post
author: Rob
title: What's the Deal With Support Material
published: true
---
<table class="image" style="margin: auto;">
  <caption align="bottom">FFF printed "Stanford Bunny" with support material still intact, courtesy of <a href="https://www.flickr.com/photos/creative_tools/14485075381/in/photolist-o4ZNfZ-o75bFH-h8WN15-nahjC9-g1KXpN-gwmN7H-gwmAC2-g1Ljrp-g1KNQJ-g1L4mK-g1EDcJ-gwmFi5-o2yj1i-g1L3vt-ee57X9-o7bjmH-gkrQXZ-7FfGcB-oi4wBJ-fqvWhC-fDVtrM-fDVyWc-fEcuRh-fEcDX3-fDUVwn-dZngZU-dZnhnd-e9W6k8-nahjDm-jjWWDL-5nhASg-bkqCjC-bogJSF-bogJJn-jjUqDh-jjTT7P-jjUoJA-yqXXP-a7qBdv-kM4tbZ-dZnPMW-dZnPko-omRjVe-k1mFee-nZmZCp-e9ceij-awarjT-5YyHH5-nZnL8p-oiBgKn" target="_blank">Creative Tools</a> under <a href="https://creativecommons.org/licenses/by/2.0/legalcode" target="_blank">CC BY 2.0</a>.</caption>
<tr><td>
<img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/bunny_support.jpg" width="936">
</td></tr>
</table>

<br><p><i>Gravity is the archnemesis of the adventurous 3D printer.</i></p>

<p><strong>The problem:</strong> 3D printers build parts one cross section at a time, printing each layer on top of the last. So what happens when the printer encounters an overhang, with no base layer to print on? Then, gravity takes over, the layer tumbles down to the build table, and the part is ruined. Some of the world’s best engineers have put their minds to the issue and have developed a way to 3D print parts with extremely complex geometries.</p>
<p><strong>The solution:</strong> Support material. Simply print a removable scaffolding below the overhangs and rest easy knowing that those overhangs cannot fail. </p>

<p>We will look at some of the most popular 3D printing methods that require support material: SLA, FDM, FFF, and DMLS. Want to learn more about these methods? <a href="www.supplybetter.com/blog" target="_blank">Visit our blog</a>.
<p>While the benefits of support structures are obvious, we will see that the use of support material often returns unfortunate consequences.</p>

<h4>But first: how does the printer know where to put the support?</h4>
<p>This problem is solved by software. Most slicers, programs that take a CAD file and split it into cross sections to be printed, can also automatically add the necessary support to the design. For example, FDM printers, made by Stratasys, use the Insight software package to orient and support parts.</p>

<h4>SLA:</h4>
<p>Because the <a href="www.supplybetter.com/blog/what-to-expect-with-sla.html" target="_blank">SLA process</a> inherently supports any overhangs with un-hardened resin, one might imagine that no support material was necessary. However, fluctuations in the resin caused by the build table moving, compounded with the general instability of the liquid resin, necessitate a more solid support structure. This is achieved by hardening key vertical support “columns” in the resin, below where the overhangs are planned. These supports can be snapped off after the part is removed from the vat, and before the part is post-processed in the curing oven. Visible nubs are often left where the support was attached to the part. These must be removed by copious sanding or bead blasting, which adds costly man-hours to the process.</p>

<table class="image" style="margin: auto;">
  <caption align="bottom">(Left) "Mr. Piggy with support material," an FDM printed model with support material (dark) intact. The support material here was water soluble.  (Right) Blue model printed with FFF. The support material here is the same as the build material. Images courtesy of <a href="http://www.flickr.com/photos/cabfablab/3613870642/" target="_blank">Fab Lab den Haag</a> (left) and <a href="https://www.flickr.com/photos/makerbot/5234651355/in/set-72157625474608673" target="_blank">Makerbot Industries </a>(right) under <a href="https://creativecommons.org/licenses/by/2.0/legalcode" target="_blank">CC BY 2.0</a>.</caption>
<tr>
<td width="50%" align="center">
<img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/pig_support.jpg">
</td>
<td width="50%" align="center">
<img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/blue_support.jpg">
</td>
</tr>
</table>

<h4>FDM:</h4>
<p>Stratasys has developed several different proprietary materials for support in their <a href="www.supplybetter.com/blog/what-to-expect-with-fdm.html">FDM process</a>. Adding a second (support) material to a print means that multiple extruders are necessary, each printing in a single material. Support materials offered by Stratasys include include a wax material (ICW06 Wax), a Break Away Support System (BASS for short), and several soluble materials. The soluble materials may be removed by soaking the part in water or in some cases a chemical bath, and should leave almost no visible mark on the part. However, the Break Away system will leave marks.</p>

<h4>FFF:</h4>
<p>Unlike the more advanced FDM machines, FFF machines rarely have two extruders. Unfortunately, this leaves only one option for support material: the build material itself. The support structure is constructed along with the part, but with much lower infill density. This makes it faster to print and easier to remove after the print is completed. However, the surface of the part will retain bumps and other defects after the support is removed.</p>

<h4>DMLS:</h4>
<p>In the <a href="www.supplybetter.com/blog/what-to-expect-with-dmls.html">DMLS process</a>, only one type of powder can be used per part. This means that support structure must be built from the same powder as the rest of the part. It is not intuitive why DMLS parts even need support material, when parts produced by the similar <a href="www.supplybetter.com/blog/what-to-expect-with-sls.html">SLS process</a> can be supported by the excess powder alone. The difference lies in the phase changes that occur. In SLS, the goal is to heat the powder to the point of sintering only, and no further. In this way, the powder never reaches a liquid phase. In DMLS, a <a href="http://www.3trpd.co.uk/dmls.htm">liquid state</a> may be reached, and the powder alone cannot support the molten metal. Scaffolding is required underneath overhangs, and must be removed by CNC machining. Machining adds significant time and expense to the DMLS process. To preserve the accuracy of the part, the machining tools must be capable of the same tight tolerances as the printer.</p>

<p>I hope this was instructional, and as always, best of luck with your 3D printing! Don’t let gravity get you (or your overhangs) down.</p>

<p>Cheers,</p>
<p>Rob</p>