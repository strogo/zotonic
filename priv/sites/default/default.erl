%% @author Arjan Scherpenisse <arjan@scherpenisse.net>
%% @copyright 2009 Arjan Scherpenisse
%% @date 2009-12-12
%% @doc Module implementing a basic blog.

%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(default).
-author("Arjan Scherpenisse <arjan@scherpenisse.net>").

-mod_title("Default Zotonic site").
-mod_description("A simple weblog, used as an example of how to create a Zotonic site.").
-mod_prio(10).

%% gen_server exports
-export([init/1]).

-include_lib("zotonic.hrl").

%% @doc Initialize the datamodel
init(Context) ->
    z_datamodel:manage(?MODULE, datamodel(), Context).

%%====================================================================
%% support functions
%%====================================================================

datamodel() ->
    Now = {{2010,04,03},{9,12,0}},
    [
     {resources,
      [

       %% MENU ENTRIES

       {page_home,
        text,
        [{title, <<"Home">>},
         {summary, <<"Welcome to your blog!">>},
         {page_path, <<"/">>}]
       },

       {page_about,
        text,
        [{title, <<"About this blog">>},
         {summary, <<"This is your blog. It would be wise to type some text here on what you will be writing about. Ofcourse, this page is just a demo page and can be deleted just as well.">>}]
       },

       {page_contact,
        text,
        [{title, <<"Contact">>},
         {summary, <<"Get in contact with us! Use the form below to send this site's administrator some feedback on how you perceive this site.">>},
         {page_path, <<"/contact">>}]
       },


       %% BLOG ENTRIES

       {blog_article_welcome,
        article,
        [{title, <<"Welcome to Zotonic " ?ZOTONIC_VERSION "!">>},
         {publication_start, Now},
         {summary, <<"Zotonic is the content management system for people that want a fast, extensible, flexible and complete system for dynamic web sites. It is built from the ground up with rich internet applications ánd web publishing in mind.">>},
         {body, {file, filename:join([z_utils:lib_dir(priv), "sites", ?MODULE, "demodata", "welcome.html"])}}
        ]
       },
       {blog_article_learnmore,
        article,
        [{title, <<"Want to learn more?">>},
         {publication_start, z_datetime:prev_day(Now)},
         {summary, <<"This blog website you're looking demonstrates only a small part of what you can do with a Zotonic site. For instance, did you know that sending mass-mailings is a builtin module? That it does OAuth out of the box? That Zotonic sites are SEO optimized by default?">>},
         {body, {file, filename:join([z_utils:lib_dir(priv), "sites", ?MODULE, "demodata", "learnmore.html"])}}]
       },
       {blog_article_demo,
        article,
        [{title, <<"Zotonic's Typography">>},
         {publication_start, z_datetime:prev_month(Now)},
         {summary, <<"This article demonstrates the typographic features that Zotonic has. It shows creating ordered and unordered lists, blockquotes, and different methods of embedding media, even even showing an embedded video from Vimeo.com.">>},
         {body, {file, filename:join([z_utils:lib_dir(priv), "sites", ?MODULE, "demodata", "demo.html"])}}
        ]
       },

       %% KEYWORDS

       {kw_announcement,
        keyword,
        [{title, <<"Announcement">>}]
       },
       {kw_technical,
        keyword,
        [{title, <<"Technical">>}]
       },
       {kw_support,
        keyword,
        [{title, <<"Support">>}]
       }

      ]
     },

     {media,
      [
       {media_learning,
        filename:join([z_utils:lib_dir(priv), "sites", ?MODULE, "demodata", "learning.jpg"]),
        [{title, <<"A bunch of computer books">>},
         {summary, <<"Taken by Sibi from Flickr, licensed Attribution-Noncommercial-No Derivative Works 2.0.">>}]
       },
       {media_welcome,
        filename:join([z_utils:lib_dir(priv), "sites", ?MODULE, "demodata", "welcome.jpg"]),
        [{title, <<"Rocky sunrise">>},
         {summary, <<"Taken by Grant MacDonald from Flickr, CC licensed Attribution-Noncommercial 2.0.">>}]
       },
       {media_video,
        {<<"vimeo">>, <<"<object width=\"400\" height=\"225\"><param name=\"allowfullscreen\" value=\"true\" /><param name=\"allowscriptaccess\" value=\"always\" /><param name=\"movie\" value=\"http://vimeo.com/moogaloop.swf?clip_id=7630916&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=0&amp;show_portrait=0&amp;color=&amp;fullscreen=1\" /><embed src=\"http://vimeo.com/moogaloop.swf?clip_id=7630916&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=0&amp;show_portrait=0&amp;color=&amp;fullscreen=1\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\" allowscriptaccess=\"always\" width=\"400\" height=\"225\"></embed></object>">>},
        [{title, <<"Zotonic introduction video">>}]
       }
      ]
     },

     {menu,
      [page_home, page_about, page_contact]
     },

     {edges,
      [
       {blog_article_learnmore, author, administrator},
       {blog_article_welcome, author, administrator},
       {blog_article_demo, author, administrator},

       {blog_article_learnmore, subject, kw_support},
       {blog_article_demo, subject, kw_technical},
       {blog_article_welcome, subject, kw_support},
       {blog_article_welcome, subject, kw_announcement},

       {blog_article_welcome, depiction, media_welcome},
       {blog_article_learnmore, depiction, media_learning},
       {blog_article_demo, depiction, media_welcome}

      ]
     }
    ].
