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

	<p>【置顶】</p>

	<ul class="posts">
		<li>
			<a href="http://book.piginzoo.com" target="_blank">《我的投资学的电子书》</a>
		</li>


	  {% for post in site.posts %}
	  	{% if post.type=="top" %}
	    	<li>
	    		<span>{{ post.date | date: "%Y/%m/%d" }}</span> &raquo; 
	    		<a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a>
	    	</li>
	    {% endif %}
	  {% endfor %}

	</ul>

	<p>【博客】</p>

	<ul class="posts">

	  {% for post in site.posts %}
	  	{% if post.type!="private" and post.type!="top" %}
	    	<li>
	    		<span>{{ post.date | date: "%Y/%m/%d" }}</span> &raquo; 
	    		<a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a>
	    	</li>
	    {% endif %}
	  {% endfor %}

	</ul>
</div>