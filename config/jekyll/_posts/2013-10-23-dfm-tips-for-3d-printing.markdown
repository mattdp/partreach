--- 
layout: post
author: Rob
title: Design for 3D Printing - When to choose FFF vs. FDM - Materials
published: true
---
<img src="https://s3.amazonaws.com/partreach_initial_bucket/uploads/8592837554_e02715f7b1_c.jpg" width="49%">
<img src="https://s3.amazonaws.com/partreach_initial_bucket/uploads/DFM_FDM_photo.JPG" width="49%">
<div class="footer">
	(left) Frogs printing on a Makerbot out of PLA material. Layer heights from left to right are 0.1mm, 0.27mm, and 0.34mm. Image courtesy of <a target= "_blank" href="https://www.flickr.com/photos/creative_tools/">Creative Tools</a> under <a target= "_blank" href="https://creativecommons.org/licenses/by/2.0/deed.en">CC BY 2.0</a>. (right) Custom bracket 3D printed through SupplyBetter by <a target= "_blank" href="http://www.supplybetter.com/profiles/makeparts">Make-Parts.com</a>. The soluble support material is still attached in this photo (later removed in post process).
</div>

SupplyBetter loves 3D printing. For the past eight months we've seen a wide variety of projects <a href="http://www.supplybetter.com/orders/new" target="_blank">submitted through our platform</a>, and have had the pleasure of matching them to the best suppliers for the job. We've dealt with a full spectrum of 3D printing projects, ranging from small to large, one-offs to medium volume runs, and plastics to exotic materials. Some patterns have started to emerge - in particular, we deal with quite a few RFQs from people who are looking to transition from desktop printing to commercial printing or vice versa. While we have <a href="http://www.supplybetter.com/materials" target="_blank">a page dedicated to comparing various 3D printing method and materials</a>, I wanted to specifically focus on the difference in materials between FFF and FDM machines.  

###Two clarifications###

This is not a post about which 3D printer you should purchase, though <a href="http://blog.cubehero.com/2013/04/12/what-you-need-to-know-about-buying-a-3d-printer/" target="_blank">here's a great analysis on this subject</a>. This post is dedicated to discussing the material differences when using FFF and FDM, and how it may influence your design. 

Also, **Fused Filament Fabrication (FFF)** and **Fused Deposition Modeling (FDM)** 3D printing processes are <a href="http://en.wikipedia.org/wiki/Fused_filament_fabrication" target="_blank">basically the same</a>. To show how similar they are, here's a <a href="http://www.3ders.org/articles/20131014-jet-engine-made-on-a-3d-printer.html" target="_blank">scale model jet turbine made via FFF</a> compared to a <a href="http://www.youtube.com/watch?feature=player_embedded&v=ALA2Gp59_IM" target="_blank">full-scale model turbo prop made via FDM</a>. Both processes do a solid job at rapid prototyping, but there are some important nuances that should be considered when designing your parts. 

###Both are great, with limitations###

####FFF is great for####

* **Cheap prototyping** Seriously, at about <a href="http://www.octave.com/p1173433089/Octave-Natural-ABS-Filament-1.75mm-1kg-2.2lbs-Spool/product_info.html" target="_blank">$0.03 per gram</a>, this is as cheap as it gets. 
* **Fast printing** Want something in your hand as fast as possible? Set a large layer height and <a href="http://davedurant.wordpress.com/2011/10/12/ultimaker-faq-but-what-about-the-quality-of-prints/" target="_blank">watch your printer fly</a>. You can also have greater control over the infill of your print, which means you can lay down the least amount of material necessary to keep your model from collapsing in on itself. 
* **Experimentation** Want to <a href="http://3dprintingindustry.com/2013/10/14/3d-printing-land-chocolate/" target="_blank">3D print in chocolate</a>? Go for it! Want to quickly switch between PLA, ABS, and PC? Not a problem. Cheap machines are awesome for this, and if you destroy an extruder or mangle one of your stepper motors, <a href="http://reprap.org/wiki/RepRap_Buyers'_Guide" target="_blank">spare parts are readily available</a>. 

####FFF is not great for####

* **Mechanical performance** Delamination is a chief concern when printing from an FFF machine. <a href="http://www.youtube.com/watch?feature=player_embedded&v=5uJyqLZU7YI" target="_blank">Here's a great example</a> of what that can look like. In case anyone is currently experiencing delamination woes, <a href="http://www.3ders.org/articles/20120709-some-tips-for-getting-better-3d-printing-results.html" target="_blank">3ders posted some handy tips</a> for mitigating this problem (pulled from a <a href="http://www.soliforum.com/topic/3917/problem-with-layer-adhesion-i-think/" target="_blank">thorough discussion on Soliforum</a>).
* **Consistency** One of the tradeoffs made in low cost filament is consistency in cross sectional area. Ideally, if you look at 3D printing filament head-on it should be a circle, but along a stretch of filament the cross section can change from a circle to an oval, which can affect the quality of the print. <a href="http://www.protoparadigm.com/blog/2011/11/filament-tolerances-and-print-quality/" target="_blank">Protoparadigm has an incredibly thorough rundown</a> of exactly what this looks like and how you can take measures to lessen its effect on prints. 
* **Support Material** Ask someone who regularly prints using FFF how much support material they use. Their answer will likely be "as little as possible". Yes, dual extruder FFF machines are making progress with utilizing support material alongside structure material, but right now the vast majority of FFF suppliers simply use structure material (PLA, ABS, etc) for their support. Since the structure and support materials are the same, removal is tedious and the surface finish suffers (though post processing with <a href="http://www.youtube.com/watch?v=bcXLJRIKGuQ" target="_blank">acetone vapor</a> is an increasingly viable option). If you can design your parts without any need for support material then great, but if that's not possible and surface finish is important, you're better off using FDM. 

####FDM is great for####

* **Mechanical performance** These are some of the strongest plastic 3D printing parts you'll get. 
* **Consistency** Heated build chambers mean a lot less warping, which if you've talked to anyone printing ABS on a RepRap machine, is typically a big challenge
* **Production use** In certain production cases, having certified parts can be crucial. For instance, one of the great properties of Ultem is that it's <a href="http://boingboing.net/2010/09/15/hard-to-burn-lightwe.html" target="_blank">flame retardant</a>, which allows it to be certified for use in aircraft.
* **Support Material** The right-hand picture at the top of this post is an FDM part using soluble support material to accomodate for the overhangs and undercuts present in the model. Since the material is soluble there are virtually no signs of the support material once it's been removed. Awesome.
* **Large geometries** FDM build envelopes can go as large as 914 x 610 x 914 mm, as <a href="http://www.youtube.com/watch?v=W5h2d7Vyj6s&feature=player_detailpage#t=170" target="_blank">this video</a> shows (I'm ignoring <a href="http://bigthink.com/endless-innovation/why-3d-printed-houses-matter" target="_blank">3D printing for architecture applications</a> since it's worthy of an entirely separate discussion). Remember the <a href="http://www.3ders.org/articles/20130211-urbee-2-announced-the-world-first-3d-printed-car-go-for-actual-production.html" target="_blank">Urbee</a>? It was printed using FDM. If you need to print prototype cars, then this is likely how you're going to do it (however, I will add that <a href="http://www.re3d.org/#!gigabot/canh" target="_blank">Gigabot recently finished a successful Kickstarter</a> for a 600mm x 600mm x 600mm FFF printer). 

####FDM is not great for####
* **Quick and dirty printing** Like I said with FFF, if you're looking for quick and dirty, you're not going to beat desktop printers. Even if you use <a href="https://bolsonmaterials.com/Products_Overview-Rapid_Prototyping_Materials#Dimension" target="_blank">non-OEM vendors</a>, material is still going to cost you between $0.20 - $0.25 per gram. Not quite a magnitude more expensive than FFF filament, but enough to make you reconsider how much material you're using in your design (and to incentivize <a href="http://hackaday.com/2012/09/19/this-hack-can-refill-your-stratasys-3d-printer/" target="_blank">work-arounds for reloading cartridges</a>)

* **Experimentation** These machines are expensive, with the cheapest ones being <a href="http://www.engineering.com/3DPrinting/3DPrintingArticles/ArticleID/4405/Hands-on-with-the-Mojo-3D-Printer.aspx" target="_blank">the Mojo at around $10,000 USD</a>. If you're looking to experiment with different materials, I would suggest <a href="http://haveblue.org/?p=439" target="_blank">scouring Craigslist like Have Blue</a> to pick up an older model cheaply. 


###Materials possible###
Quite a wide variety of different materials have been attempted, most of which are categorized on the <a href="http://reprap.org/wiki/Category:Thermoplastic" target="_blank">RepRap wiki</a> Some have datasheets, though most do not. If you come across a datasheet for any material here that doesn't have one, let us know! We'd love to compare. 

####FFF####

* ABS (Octave Brand): <a href="https://s3.amazonaws.com/partreach_initial_bucket/uploads/PA-747R_ISO.pdf" target="_blank">datasheet</a>
* Laywoo-D3 (wood): <a href="http://www.3ders.org/articles/20130204-wood-filament-laywoo-d3-suppliers-and-price-compare.html" target="_blank">description</a>
* Nylon-618 (PLA): <a href="http://reprap.org/wiki/Taulman3D_618_Nylon" target="_blank">description</a>
* Nylon-645: <a href="http://taulman3d.com/645-features.html" target="_blank">description</a>, <a href="http://www.youtube.com/watch?v=kUkhy92ad64" target="_blank">video showing flexibility</a>
* PC: <a href="http://reprap.org/wiki/Polycarbonate" target="_blank">description</a>
	* <a href="http://www.youtube.com/watch?feature=player_detailpage&v=ZuMWhni7E2g#t=7" target="_blank">video comparing mechanical properties of ABS, PLA, and PC</a>
* PLA 4042D: <a href="http://www.natureworksllc.com/Technical-Resources/~/media/Technical_Resources/Technical_Data_Sheets/TechnicalDataSheet_4032D_films_pdf.pdf" target="_blank">datasheet</a>
* PLA 4043D: <a href="http://www.natureworksllc.com/Technical-Resources/~/media/Technical_Resources/Technical_Data_Sheets/TechnicalDataSheet_4043D_films_pdf.pdf" target="_blank">datasheet</a>
* Ingeo™ Biopolymer 2003D: <a href="https://dzevsq2emy08i.cloudfront.net/paperclip/technology_attachment_uploaded_files/34/original/TechnicalDataSheet_2003D_FFP-FSW.pdf?1370544691" target="_blank">datasheet</a>
* PVA (while possible it's not advisable)
* HIPS (support material): <a href="http://reprap.org/wiki/HIPS" target="_blank">description</a>
* Chocolate (technically a filament, but not really): <a href="http://reprap.org/wiki/Chocolate_Extrusion" target="_blank">description</a>

####FDM####

* ABSplus-430: <a href="http://www.stratasys.com/~/media/Main/Secure/material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-ABSplus-01-13-web.ashx" target="_blank">datasheet</a>
* ABS-ESD7: <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-ABS-ESD7-01-13-web.ashx" target="_blank">datasheet</a>
* ABSi: <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-* ABSi-01-13-web.ashx" target="_blank">datasheet</a>
* ABS-M30: <a href="http://www.stratasys.com/materials/fdm/abs-m30" target="_blank">datasheet</a>
	* <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/SSYS-MS-ABS-M30-PropertiesReport-01-11.ashx" target="_blank">Tensile Test</a>
* ABS-M30i: <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-M30i-01-13-web.ashx" target="_blank">datasheet</a>
* PC: <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-PC-01-13-web.ashx" target="_blank">datasheet</a>
	* <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/SSYS-MS-PC-PropertiesReport-01-11.ashx" target="_blank">Tensile Test</a>
* PC-ABS: <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-PC-ABS-01-13-web.ashx" target="_blank">datasheet</a>
* PC-ISO: <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-PC-ISO-01-13-web.ashx" target="_blank">datasheet</a>
* PPSF/PPSU: <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-PPSF-01-13-web.ashx" target="_blank">datasheet</a>
* ULTEM 9085: <a href="http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-ULTEM9085-01-13-web.ashx" target="_blank">datasheet</a>
	* <a href="http://www.stratasys.com/~/media/Main/Files/FDM%20Test%20Reports/Mechanical%20Properties%20of%20Ultem%20FDM%20Parts.ashx" target="_blank">Tensile Test</a>
* Support Material: There's soluble and break-away kinds, both of which appear to proprietary (even though break-away looks surprising like HIPS). 

Also, <a href="http://www.stratasys.com/materials/fdm/compare-fdm-materials" target="_blank">here's a great comparison</a> of materials on the Stratasys website (including support material).

###The Future of FFF materials###

Overall, I feel like there's a lot of room to innovate with different filament materials. The RepRap community has shown that they are willing to try printing with just about everything under the sun, while the Stratasys has definitely pushed the envelope with reliability and consitency. I'm optimistic that we'll see even more interesting materials very soon in the future. 

Also, while this isn't strictly related to FFF or FDM, <a href="http://www.indiegogo.com/projects/high-quality-3d-printer-resin" target="_blank">MadeSolid recently launched a Kickstarter</a> featuring some all-new materials for the SLA machines.

Still have questions? Feel free to <a href="http://www.supplybetter.com/orders/new" target="_blank">submit an RFQ</a> if you would like us to match with you with the right suppliers for your project. 

Cheers,

Rob

<div class="footer">
    SupplyBetter's mission is to find the best supplier match for your manufacturing needs. The opinions expressed in this post are the author's alone. 
</div>