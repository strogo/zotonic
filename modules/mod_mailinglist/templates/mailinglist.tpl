{% extends "page.tpl" %}

{% block title %}{{ m.rsc[id].title }}{% endblock %}

{% block content %}

<section id="content-wrapper" class="clearfix">
	<article id="content">
		<div class="padding">
			<h1>{{ m.rsc[id].title }}</h1>
	
			<p class="summary">{{ m.rsc[id].summary }}</p>

			{% mailinglist_subscribe id=id %}

			{{ m.rsc[id].body }}
			
			<h2>All mailing lists</h2>

			{% for title, id in m.search[{all_bytitle cat="mailinglist"}] %}
				{% ifnotequal m.rsc[id].name "mailinglist_test" %}
					<h3><a href="{{ m.rsc[id].page_url }}">{{ m.rsc[id].title }}</a></h3>
					<p>{{ m.rsc[id].summary }}</p>
				{% endifnotequal %}
			{% empty %}
			{% endfor %}

		</div>
	</article>
	
	</aside>
</section>

{% endblock %}