--- 
layout: post
author: Rob
title: Design for 3D Printing - When to choose FFF vs. FDM - Materials
published: true
---
<img src="https://s3.amazonaws.com/partreach_initial_bucket/uploads/8592837554_e02715f7b1_c.jpg" width="49%">
<img src="https://s3.amazonaws.com/partreach_initial_bucket/uploads/DFM_FDM_photo.JPG" width="49%">
<div class="footer">
	(left) Frogs printing on a Makerbot out of PLA material. Layer heights from left to right are 0.1mm, 0.27mm, and 0.34mm. Image courtesy of <a href="https://www.flickr.com/photos/creative_tools/">Creative Tools</a> under <a href="https://creativecommons.org/licenses/by/2.0/deed.en">CC BY 2.0</a>. (right) Custom bracket 3D printed through SupplyBetter by <a href="https://supplybetter.com/profiles/makeparts">Make-Parts.com</a>. The soluble support material is still attached in this photo (later removed in post process).
</div>

SupplyBetter loves 3D printing. For the past eight months we've seen a wide variety of projects [submitted through our platform](http://www.supplybetter.com/orders/new), and have had the pleasure of matching them to the best suppliers for the job. We've dealt with a full spectrum of 3D printing projects, ranging from small to large, one-offs to medium volume runs, and plastics to exotic materials. Some patterns have started to emerge - in particular, we deal with quite a few RFQs from people who are looking to transition from desktop printing to commercial printing or vice versa. While we have [a page dedicated to comparing various 3D printing method and materials](http://www.supplybetter.com/materials), I wanted to specifically focus on the difference in materials between FFF and FDM machines.  

###Two clarifications###

This is not a post about which 3D printer you should purchase, though [here's a great analysis on this subject](http://blog.cubehero.com/2013/04/12/what-you-need-to-know-about-buying-a-3d-printer/). This post is dedicated to discussing the material differences when using FFF and FDM, and how it may influence your design. 

Also, **Fused Filament Fabrication (FFF)** and **Fused Deposition Modeling (FDM)** 3D printing processes are [basically the same](http://en.wikipedia.org/wiki/Fused_filament_fabrication). To show how similar they are, here's a [scale model jet turbine made via FFF](http://www.3ders.org/articles/20131014-jet-engine-made-on-a-3d-printer.html) compared to a [full-scale model turbo prop made via FDM](http://www.youtube.com/watch?feature=player_embedded&v=ALA2Gp59_IM). Both processes do a solid job at rapid prototyping, but there are some important nuances that should be considered when designing your parts. 

###Both are great, with limitations###

####FFF is great for####

* **Cheap prototyping** Seriously, at about [$0.03 per gram](http://www.octave.com/p1173433089/Octave-Natural-ABS-Filament-1.75mm-1kg-2.2lbs-Spool/product_info.html), this is as cheap as it gets. 
* **Fast printing** Want something in your hand as fast as possible? Set a large layer height and [watch your printer fly](http://davedurant.wordpress.com/2011/10/12/ultimaker-faq-but-what-about-the-quality-of-prints/). You can also have greater control over the infill of your print, which means you can lay down the least amount of material necessary to keep your model from collapsing in on itself. 
* **Experimentation** Want to [3D print in chocolate](http://3dprintingindustry.com/2013/10/14/3d-printing-land-chocolate/)? Go for it! Want to quickly switch between PLA, ABS, and PC? Not a problem. Cheap machines are awesome for this, and if you destroy an extruder or mangle one of your stepper motors, [spare parts are readily available](http://reprap.org/wiki/RepRap_Buyers'_Guide). 

####FFF is not great for####

* **Mechanical performance** Delamination is a chief concern when printing from an FFF machine. [Here's a great example](http://www.youtube.com/watch?feature=player_embedded&v=5uJyqLZU7YI) of what that can look like. In case anyone is currently experiencing delamination woes, [3ders posted some handy tips](http://www.3ders.org/articles/20120709-some-tips-for-getting-better-3d-printing-results.html) for mitigating this problem (pulled from a [thorough discussion on Soliforum](http://www.soliforum.com/topic/3917/problem-with-layer-adhesion-i-think/)).
* **Consistency** One of the tradeoffs made in low cost filament is consistency in cross sectional area. Ideally, if you look at 3D printing filament head-on it should be a circle, but along a stretch of filament the cross section can change from a circle to an oval, which can affect the quality of the print. [Protoparadigm has an incredibly thorough rundown](http://www.protoparadigm.com/blog/2011/11/filament-tolerances-and-print-quality/) of exactly what this looks like and how you can take measures to lessen its effect on prints. 
* **Support Material** Ask someone who regularly prints using FFF how much support material they use. Their answer will likely be "as little as possible". Yes, dual extruder FFF machines are making progress with utilizing support material alongside structure material, but right now the vast majority of FFF suppliers simply use structure material (PLA, ABS, etc) for their support. Since the structure and support materials are the same, removal is tedious and the surface finish suffers (though post processing with [acetone vapor](http://www.youtube.com/watch?v=bcXLJRIKGuQ) is an increasingly viable option). If you can design your parts without any need for support material then great, but if that's not possible and surface finish is important, you're better off using FDM. 

####FDM is great for####

* **Mechanical performance** These are some of the strongest plastic 3D printing parts you'll get. 
* **Consistency** Heated build chambers mean a lot less warping, which if you've talked to anyone printing ABS on a RepRap machine, is typically a big challenge
* **Production use** In certain production cases, having certified parts can be crucial. For instance, one of the great properties of Ultem is that it's [flame retardant](http://boingboing.net/2010/09/15/hard-to-burn-lightwe.html), which allows it to be certified for use in aircraft.
* **Support Material** The right-hand picture at the top of this post is an FDM part using soluble support material to accomodate for the overhangs and undercuts present in the model. Since the material is soluble there are virtually no signs of the support material once it's been removed. Awesome.
* **Large geometries** FDM build envelopes can go as large as 914 x 610 x 914 mm, as [this video](http://www.youtube.com/watch?v=W5h2d7Vyj6s&feature=player_detailpage#t=170) shows (I'm ignoring [3D printing for architecture applications](http://bigthink.com/endless-innovation/why-3d-printed-houses-matter) since it's worthy of an entirely separate discussion). Remember the [Urbee](http://www.3ders.org/articles/20130211-urbee-2-announced-the-world-first-3d-printed-car-go-for-actual-production.html)? It was printed using FDM. If you need to print prototype cars, then this is likely how you're going to do it (however, I will add that [Gigabot recently finished a successful Kickstarter](http://www.re3d.org/#!gigabot/canh) for a 600mm x 600mm x 600mm FFF printer). 

####FDM is not great for####
* **Quick and dirty printing** Like I said with FFF, if you're looking for quick and dirty, you're not going to beat desktop printers. Even if you use [non-OEM vendors](https://bolsonmaterials.com/Products_Overview-Rapid_Prototyping_Materials#Dimension), material is still going to cost you between $0.20 - $0.25 per gram. Not quite a magnitude more expensive than FFF filament, but enough to make you reconsider how much material you're using in your design (and to incentivize [work-arounds for reloading cartridges](http://hackaday.com/2012/09/19/this-hack-can-refill-your-stratasys-3d-printer/))

* **Experimentation** These machines are expensive, with the cheapest ones being [the Mojo at around $10,000 USD](http://www.engineering.com/3DPrinting/3DPrintingArticles/ArticleID/4405/Hands-on-with-the-Mojo-3D-Printer.aspx). If you're looking to experiment with different materials, I would suggest [scouring Craigslist like Have Blue](http://haveblue.org/?p=439) to pick up an older model cheaply. 


###Materials possible###
Quite a wide variety of different materials have been attempted, most of which are categorized on the [RepRap wiki](http://reprap.org/wiki/Category:Thermoplastic) Some have datasheets, though most do not. If you come across a datasheet for any material here that doesn't have one, let us know! We'd love to compare. 

####FFF####

* ABS (Octave Brand): [datasheet](https://s3.amazonaws.com/partreach_initial_bucket/uploads/PA-747R_ISO.pdf)
* Laywoo-D3 (wood): [description](http://www.3ders.org/articles/20130204-wood-filament-laywoo-d3-suppliers-and-price-compare.html)
* Nylon-618 (PLA): [description](http://reprap.org/wiki/Taulman3D_618_Nylon)
* Nylon-645: [description](http://taulman3d.com/645-features.html), [video showing flexibility](http://www.youtube.com/watch?v=kUkhy92ad64)
* PC: [description](http://reprap.org/wiki/Polycarbonate)
	* [video comparing mechanical properties of ABS, PLA, and PC](http://www.youtube.com/watch?feature=player_detailpage&v=ZuMWhni7E2g#t=7)
* PLA 4042D: [datasheet](http://www.natureworksllc.com/Technical-Resources/~/media/Technical_Resources/Technical_Data_Sheets/TechnicalDataSheet_4032D_films_pdf.pdf)
* PLA 4043D: [datasheet](http://www.natureworksllc.com/Technical-Resources/~/media/Technical_Resources/Technical_Data_Sheets/TechnicalDataSheet_4043D_films_pdf.pdf)
* Ingeo™ Biopolymer 2003D: [datasheet](https://dzevsq2emy08i.cloudfront.net/paperclip/technology_attachment_uploaded_files/34/original/TechnicalDataSheet_2003D_FFP-FSW.pdf?1370544691)
* PVA (while possible it's not advisable)
* HIPS (support material): [description](http://reprap.org/wiki/HIPS)
* Chocolate (technically a filament, but not really): [description](http://reprap.org/wiki/Chocolate_Extrusion)

####FDM####

* ABSplus-430: [datasheet](http://www.stratasys.com/~/media/Main/Secure/material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-ABSplus-01-13-web.ashx)
* ABS-ESD7: [datasheet](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-ABS-ESD7-01-13-web.ashx)
* ABSi: [datasheet](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-* ABSi-01-13-web.ashx)
* ABS-M30: [datasheet](http://www.stratasys.com/materials/fdm/abs-m30)
	* [Tensile Test](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/SSYS-MS-ABS-M30-PropertiesReport-01-11.ashx)
* ABS-M30i: [datasheet](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-M30i-01-13-web.ashx)
* PC: [datasheet](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-PC-01-13-web.ashx)
	* [Tensile Test](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/SSYS-MS-PC-PropertiesReport-01-11.ashx)
* PC-ABS: [datasheet](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-PC-ABS-01-13-web.ashx)
* PC-ISO: [datasheet](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-PC-ISO-01-13-web.ashx)
* PPSF/PPSU: [datasheet](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-PPSF-01-13-web.ashx)
* ULTEM 9085: [datasheet](http://www.stratasys.com/~/media/Main/Secure/Material%20Specs%20MS/Fortus-Material-Specs/Fortus-MS-ULTEM9085-01-13-web.ashx)
	* [Tensile Test](http://www.stratasys.com/~/media/Main/Files/FDM%20Test%20Reports/Mechanical%20Properties%20of%20Ultem%20FDM%20Parts.ashx)
* Support Material: There's soluble and break-away kinds, both of which appear to proprietary (even though break-away looks surprising like HIPS). 

Also, [here's a great comparison](http://www.stratasys.com/materials/fdm/compare-fdm-materials) of materials on the Stratasys website (including support material).

###The Future of FFF materials###

Overall, I feel like there's a lot of room to innovate with different filament materials. The RepRap community has shown that they are willing to try printing with just about everything under the sun, while the Stratasys has definitely pushed the envelope with reliability and consitency. I'm optimistic that we'll see even more interesting materials very soon in the future. 

Also, while this isn't strictly related to FFF or FDM, [MadeSolid recently launched a Kickstarter](http://www.indiegogo.com/projects/high-quality-3d-printer-resin) featuring some all-new materials for the SLA machines.

Still have questions? Feel free to [submit an RFQ](http://www.supplybetter.com/orders/new) if you would like us to match with you with the right suppliers for your project. 

Cheers,

Rob

<div class="footer">
    SupplyBetter's mission is to find the best supplier match for your manufacturing needs. The opinions expressed in this post are the author's alone. 
</div>