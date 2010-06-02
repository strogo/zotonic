{% extends "admin_base.tpl" %}

{% block title %}{_ Log _}{% endblock %}

{% block content %}

	<div id="content" class="zp-85">
		<div class="block clearfix">

		<h2>Log messages</h2>

			<form id="{{ #form }}" method="GET" action="{% url admin_overview_rsc qs=q.qs %}">
				<input type="hidden" name="qsort" value="{{ q.qsort }}" />
				<input type="hidden" name="qs" value="{{ q.qs }}" />
				<h3 class="above-list ">
					{_ Most recent messages _}
				</h3>
			</form>

            {% with m.search[{log page=q.page pagelen=20}] as result %}
            <ul class="short-list">
                <li class="headers clearfix" id="log-headers">
                    <span class="zp-5">{_ Type _}</span>
                    <span class="zp-10">{_ Module _}</span>
                    <span class="zp-60">{_ Message _}</span>
                    <span class="zp-15">{_ User _}</span>
                    <span class="zp-10">{_ Date _}</span>
                </li>
            </ul>

            <div class="wrapper" style="height: 620px; overflow: auto">
                <ul class="short-list" id="log-area">

                    {% for id in result %}
                    {% include "_admin_log_row.tpl" id=id %}
                    {% empty %}
                    <li>
                        {_ No log messages. _}
                    </li>
                    {% endfor %}
                </ul>
                {% button text="more..." action={moreresults result=result target="log-area" template="_admin_log_row.tpl"} %}
            </div>
            {% endwith %}
        </ul>

		{% logwatch %}
		</div>
	</div>

{% endblock %}