--- 
layout: post
author: Rob
title: Injection Molding through Alibaba | Case Study
published: true
meta_description: SupplyBetter helped produce an injection molded custom part for Saturday Morning Breakfast Cereal (SMBC). Case study here. 
---
<div style="display:inline-block; max-width:100%; float:left">
<a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/supplybetter-gulpo-manufacturing-case-study-large-20.png" target="_blank"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/supplybetter-gulpo-manufacturing-case-study-medium-18.png"></a>
</div>
<div class="footer" align="bottom">Old Gulpo (right), New Gulpo (left)</div>

<h1>Intro</h1>

This post is about one, relatively simple, hardware product and how SupplyBetter helped get it made. Our goal is to provide as detailed an account of the steps involved so that those currently in the middle of (or about to embark on) a serious hardware project can learn from our experience. Finding a company to make the parts for a custom product that can't be bought from a website or catalog (a.k.a "outsourcing") can be incredibly difficult because it is the intersection of engineering and business. You can be skilled in engineering or a solid business developer, but if you're not good at both you can quickly find yourself ill-equipped to address the tradeoffs that need to be made in order to manufacture your product.

From our perspective we had the privilege of taking on a near-ideal case study that shows the risks involved, difficult decisions that have to made, and attention to detail necessary (on both a business and technical front) to source any hardware product. While the product itself was relatively simple, the insights gained and lessons learned apply to anyone looking to get into hardware. 

<h1>Project Background</h1>
<div style="display:inline-block; max-width:50%; float:left">
  <a href="http://www.smbc-comics.com/?id=2094" target="_blank"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/Saturday_Morning_Breakfast_Cereal-small.png"></a>
</div>
<div style="display:inline-block; max-width:50%; float:left">
  <a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/supplybetter-gulpo-manufacturing-case-study-large-21.jpg" target="_blank"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/supplybetter-gulpo-manufacturing-case-study-small-21.jpg"></a>
</div>
<div class="footer" align="bottom">(Left) The comic that started it all. (Right) The original, laser cut Gulpo.</div>

People love Gulpo. And so do we. 

Gulpo is a novelty car emblem conceived by Zach Weinersmith and the Saturday Morning Breakfast Cereal team. After Gulpo made its debut on their <a href="http://www.smbc-comics.com/?id=2094" target="_blank">daily-updated webcomic</a> in late 2010, there was large demand from SMBC's fanbase to actually produce these car emblems for sale on SMBC's website. After finding someone who could produce a small batch, Gulpo went on sale in the winter of 2013-14 and quickly sold out. Gulpo was a success. 

<h1>The Problem</h1>

tl;dr: SMBC could not make larger batches due to the limitations imposed by the manufacturing process used to produce the first batch of Gulpos.

<div style="display:inline-block; max-width:50%; float:left">
  <a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/gulpo_graph-large.png" target="_blank"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/gulpo_graph-medium.png"></a>
</div>
<div style="display:inline-block; max-width:50%; float:left">
 <a href="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/supplybetter-gulpo-manufacturing-case-study-large-17-fixed-large.png" target="_blank"><img src="https://s3.amazonaws.com/supplybetter_images/Blog+Images/141107-gulpo_case_study/supplybetter-gulpo-manufacturing-case-study-large-17-fixed-small.png"></a>
</div>
<div class="footer" align="bottom">(Left) The manufacturing chosen for Gulpo isn't suitable for larger volumes. Compared to injection molding, the transition point occurs at around QTY 50.(Right) Problem with the original Gulpo design. </div>

Despite the success of the first run of Gulpos, it didn't make sense to produce another run. Not including their time spent sourcing and managing the first production run, SMBC just barely broke even selling Gulpo Version 1. It was too expensive to manufacture given their current method, and the product didn't look as good as they wanted it to. Their choice of laser cutting as the manufacturing process for this first run of Gulpos was not suitable going forward for two reasons. 

<h3>Benefits of Laser cutting for prototyping</h3> 
Gulpo Version 1 was laser cut from black plastic with a chrome front face. The adhesive backing was also laser cut to match the profile of the design. Laser cutting was a great choice for the initial batch of Gulpos since the design is 2D and there is very little setup cost to cut the design. This is important because if SMBC was going to sell this product, they needed to validate that there was actually a market willing to buy them at a price that made sense. Putting in the effort and money needed to produce a Gulpo that exactly matched the aesthetics of an Icthys-themed novelty car emblem wouldn't matter if no one wanted to buy it. Thus, choosing laser cutting as their manufacturing process meant they could validate their biggest assumption while minimizing their upfront costs to actually make the fish.  

<h3>Drawbacks of Laser cutting for production</h3> 
Laser cutting's initial blessing of having a negligible setup cost quickly becomes a curse once production quantities begin approaching larger volumes. Laser cutting is a fixed-time manufacturing process, which means that the time-per-Gulpo for QTY 1 is the same as QTY 500. In other words, the cost of making Gulpo is relatively fixed, regardless of the quantity being produced. Considering that SMBC only broke even with the last batch, they wouldn't expect their margins to improve by order a large amount*. If SMBC really wanted Gulpo to make sense as a retail product, they were going to need to find a different way to produce them. 

<h3>Improvement on Aesthetics</h3> 
As mentioned before, the main goal of the initial batch of Gulpos was to validate that people actually wanted to purchase this product. Aesthetic were not a concern as long as they were good enough to validate this assumption (what is commonly referred to as the Minimum Viable Product a.k.a. MVP). Now that their initial assumption was firmly validated, SMBC wanted the next Gulpo to look as much like a car emblem you'd see in the wild as possible. This required a smooth and glossy chrome-on-black surface finish and an adhesive backing that would not fall off a car bumper regularly exposed to the elements. While laser cutting was able to produce a chrome against black surface finish, the results were not smooth or glossy. The surface finish wasn't smooth mainly due to the resolution of the laser cutter used, which etches the material by burning the surface line by line. While there are some great optimizations that can be done to improve the quality of images raster etched via laser cutting, you're not going to be able to produce a surface finish smooth enough to be glossy without a fair amount of post processing (i.e. sanding and/or polishing). Adding post processing as an additional step would only increase the price per unit. 

Simply put, if SMBC wanted a better product for cheaper they would need to take a fundamentally different approach.

<h1>Solution</h1>

tl;dr: SupplyBetter needed to find a shop with the right capabilities in (likely overseas) in order to meet their project needs.

To better understand the decision made in making Version 2 Gulpo, here is a summary of specifications from the previous section:

<h3>Technical requirements</h3>
<ul>
<li>Same 2D design as Version 1 Gulpo (e.g. letter font, outer dimensions, etc)</li>
<li>A smooth and glossy surface finish</li>
<li>Colors to be used are silver chrome and glossy black</li>
<li>Durable enough material and strong enough adhesive backing to withstand exposure to the elements while affixed to the back of a car</li>
</ul>
<h3>Buyer Business requirements</h3>
<ul>
<li>Want the ability to produce in batches of 1500+ </li>
<li>Per-unit cost to SMBC needs to be low enough to make financial sense to sell at their current price</li>
</ul>
<h3>Supplier Capability requirements</h3>
<ul>
<li>Injection molding</li>
<li>Mold polishing</li>
<li>Two color painting</li>
<li>Die cutting</li>
<li>Large batch production</li>
</ul>
<h3>Business specification</h3>
<ul>
<li>Already makes products similar to Gulpo</li>
<li>Willing to send product samples</li>
<li>Can work with an Minimum Order Quantity (MOQ) of ~1000 pieces</li>
<li>Willing to work off of milestone payments (vs. timelines)</li>
</ul>
<h3>Rough manufacturing process outline</h3>
<ol>
<li>Mill the injection mold tooling</li>
<li>Polish the tooling (to achieve a glossy surface finish on the parts)</li>
<li>Paint chrome (all over the part)</li>
<li>Paint matte black in recessed areas of design</li>
<li>Die cut the adhesive backing</li>
<li>Assembly adhesive backing and painted piece</li>
</ol>

Given the above specs, an injection molded body with a die-cut adhesive backing made the most sense as the manufacturing methods of choice. Injection molding is fantastically suited for high-volume production of thermoplastics, which is why you see it being used in the majority of consumer products today. Chances are whatever device you're using to read this has an injection molded component in it. This would be the most critical process to source around. Now that we knew what kind of supplier we were looking for, it was time to actually go out there and find them. 

<h1>Identify Suppliers</h1>

<a href="http://styledemocracy.com/wp-content/uploads/2014/07/alibaba-logo.jpg" target="_blank"><img src="http://styledemocracy.com/wp-content/uploads/2014/07/alibaba-logo.jpg"></a>

SupplyBetter prides itself in finding that handful of suppliers who are the exact match for the job. It's more than simply knowing which suppliers are "good" and which suppliers are "bad". You need to determine which suppliers are the most capable to work on your project. We believe that parts will be better and cheaper if you start your vendor relationship with a company that already as the equipment necessary and understands nuances of the manufacturing processes involved. Manufacturing vendors are more than just machines with spare capacity, it's the engineers and tradesmen behind them that truly make your products great. 

That said, we did not yet have a supplier network established overseas. So where do you go right now when you need a consumer product made overseas? Alibaba. 

Alibaba can be ridiculously intimidating. A common perception held by hardware designers is that reaching out to suppliers on Alibaba can be akin to directly emailing scammers to let them know you're their newest victim. While there are indeed quality suppliers to be found on Alibaba's marketplace, having an entire ocean and legal system between you and the people you're sending money to means there is very little recourse to be had for manufacturing deals gone awry. The suspicion that you may be dealing with a fraudulent company is not unfounded.[cite] This why the in-person Asian factory tour is such a common to occurrence with hardware companies sourcing overseas. For excellent first-person accounts of what the manufacturing ecosystem looks like, I highly recommend bunnie's blog (for electronics) and The Open Company's blog (for sourcing and how it affects local culture) [cite bunnie and TOC].

Neither SMBC nor SupplyBetter was willing to jump on a plane and go on a factory tour simply to make this one part. The cost of the plane tickets alone would likely amount to more than the cost of the entire production run. For this project we were stuck with online resources and our wits.

Alibaba is best navigated by searching for similar products currently made by manufacturers (vs. just finding everyone who does "injection molding", or has a certain type of machine built for injection molding). We initially thought to searching for "custom car decals", but that query was too vague and returned hundreds of shops making everything from bumper stickers to name plates. We decided to swing the pendulum the opposite way and get as specific as possible. Oddly enough, there were a handful of suppliers who were advertising as producers of "Icthys-themed novelty car emblems" (try it!). Vendors often post pictures of parts they make, and we were seeing examples of the Christian fish, Darwin evolution emblem, and Flying Spaghetti Monster. [find the screenshots/links sent to SMBC]

With our search term figured out, it was time to start checking boxes. Alibaba has a bevy of filters you can use to narrow your search result even further, and the general advice we'd gotten from those experienced with Alibaba or Aliexpress was to just check all of them. Once done, we were down to 6 suppliers. This was as good as we were going to get. 

<h1>What we'll cover in Part II</h1>
<p><strong>The Road to Gulpo</strong></p>
<ol>
  <li><s>Characterize the project</s></li>
  <li><s>Identify Suppliers</s></li>
  <li>Initial Supplier Reachout</li>
  <li>Create RFQ Package</li>
  <li>Send RFQ Package</li>
  <li>Evaluate Quotes</li>
  <li>Order Samples</li>
  <li>Evaluate Samples</li>
  <li>Ask for buyer references (see if there is anyone else who has used them we can speak with)</li>
  <li>Enter into NDA with supplier (optional)</li>
  <li>Re-quote with final file</li>
  <li>Negotiate finance terms (e.g. establish escrow, % payment up front, etc)</li>
  <li>Order first articles (mold fee, QTY 10 units, shipping of first batch)</li>
  <li>Evaluate first articles</li>
  <li>Proceed with full production</li>
  <li>Final Quality Control</li>
  <li>Profit</li>
</ol>

Cheers,
Rob