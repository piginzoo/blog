---
layout: page
title: 首页
header: 首页
tagline: 
group: navigation
order: 1
---
{% include JB/setup %}

    

<div class="bodystyle1">

	<ul class="posts">

	  {% for post in site.posts %}
	  	{% if post.type!="private" %}
	    	<li>
	    		<span>{{ post.date | date: "%Y/%m/%d" }}</span> &raquo; 
	    		<a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a>
	    	</li>
	    {% endif %}
	  {% endfor %}

	</ul>

	<script>
	var _hmt = _hmt || [];
	(function() {
	  var hm = document.createElement("script");
	  hm.src = "https://hm.baidu.com/hm.js?4f15791b60e0e80346b6b4307165244a";
	  var s = document.getElementsByTagName("script")[0]; 
	  s.parentNode.insertBefore(hm, s);
	})();
	</script>

</div>