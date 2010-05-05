%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2010 Marc Worrell
%% @date 2010-04-27
%% @doc Access control for Zotonic.  Interfaces to modules implementing the ACL events.

-module(z_acl).
-author("Marc Worrell <marc@worrell.nl>").

-export([
	is_allowed/3,

	rsc_visible/2,
	rsc_editable/2,
	rsc_deletable/2,

	rsc_update_check/3,
	
	args_to_visible_for/1,
	set_visible_for/2,
	can_see/1,
	cache_key/1,
	
    user/1,
	sudo/1,
    sudo/2,
    anondo/1,
    anondo/2,
    logon/2,
    logoff/1
]).

-include_lib("zotonic.hrl").


%% @doc Check if an action is allowed for the current actor.
is_allowed(_Action, _Object, #context{acl=admin}) ->
	true;
is_allowed(admin, _Object, #context{user_id=?ACL_ADMIN_USER_ID}) ->
    true;
is_allowed(Action, Object, Context) ->
	case z_notifier:first({acl_is_allowed, Action, Object}, Context) of
		undefined -> false;
		Answer -> Answer
	end.


%% @doc Check if the resource is visible for the current user
rsc_visible(Id, #context{user_id=UserId}) when Id == UserId andalso is_integer(UserId) ->
    % Can always see myself
    true;
rsc_visible(_Id, #context{user_id=?ACL_ADMIN_USER_ID}) ->
	true;
rsc_visible(_Id, #context{acl=admin}) ->
	true;
rsc_visible(Id, Context) ->
	case z_memo:is_enabled(Context) of
		true ->
			case z_memo:get({rsc_visible, Id}) of
				undefined ->
					Visible = is_allowed(view, Id, Context),
					z_memo:set({rsc_visible, Id}, Visible),
					Visible;
				Visible ->
					Visible
			end;
		false ->
			is_allowed(view, Id, Context)
	end.

%% @doc Check if the resource is editable by the current user
rsc_editable(_Id, #context{user_id=undefined}) ->
    % Anonymous visitors can't edit anything
    false;
rsc_editable(Id, #context{user_id=UserId}) when Id == UserId andalso is_integer(UserId) ->
    % Can always edit myself
    true;
rsc_editable(_Id, #context{acl=admin}) ->
	true;
rsc_editable(Id, Context) ->
	is_allowed(update, Id, Context).


%% @doc Check if the resource is deletable by the current user
rsc_deletable(_Id, #context{user_id=undefined}) ->
    % Anonymous visitors can't delete anything
    false;
rsc_deletable(_Id, #context{acl=admin}) ->
	true;
rsc_deletable(Id, Context) ->
	is_allowed(delete, Id, Context).


%% @doc Filter the properties of an update.  This is before any escaping.
rsc_update_check(Id, Props, Context) ->
	z_notifier:foldl({acl_rsc_update_check, Id}, Props, Context).
		

%% @doc Set the acl fields of the context for the 'visible_for' setting.  Used when rendering scomps.
%% @spec set_visible_for(integer(), context()) -> context()
%% @todo Change this for the pluggable ACL
set_visible_for(_VisibleFor, #context{user_id=undefined} = Context) ->
    Context;
set_visible_for(?ACL_VIS_PUBLIC, Context) ->
    Context#context{user_id=undefined, acl=undefined};
set_visible_for(?ACL_VIS_COMMUNITY, Context) ->
    Context#context{user_id=?ACL_ANONYMOUS_USER_ID, acl=undefined};
set_visible_for(?ACL_VIS_GROUP, Context) ->
    Context#context{acl=undefined};
set_visible_for(?ACL_VIS_USER, Context) ->
    Context.


%% @doc Return the max visible_for the current user can see
can_see(#context{user_id=undefined}) ->
	?ACL_VIS_PUBLIC;
can_see(#context{user_id=?ACL_ADMIN_USER_ID}) ->
    ?ACL_VIS_USER;
can_see(#context{acl=admin}) ->
    ?ACL_VIS_USER;
can_see(#context{user_id=?ACL_ANONYMOUS_USER_ID}) ->
    ?ACL_VIS_COMMUNITY;
can_see(Context) ->
	case z_notifier:first({acl_can_see}, Context) of
		undefined -> [];
		CanSee -> CanSee
	end.


%% @doc Translate "visible_for" parameter to the appropriate visibility level.
%% @spec visible_for(proplist()) -> 0 | 1 | 2 | 3
args_to_visible_for(Args) ->
    case proplists:get_value(visible_for, Args) of
        undefined   -> ?ACL_VIS_USER;
        "user"      -> ?ACL_VIS_USER;
        3           -> ?ACL_VIS_USER;
        "group"     -> ?ACL_VIS_GROUP;
        2           -> ?ACL_VIS_GROUP;
        "community" -> ?ACL_VIS_COMMUNITY;
        1           -> ?ACL_VIS_COMMUNITY;
        "world"     -> ?ACL_VIS_PUBLIC;
        "public"    -> ?ACL_VIS_PUBLIC;
        0           -> ?ACL_VIS_PUBLIC
    end.


%% @doc Return a term that can be used as the ACL part of cache key.
%% @spec cache_key(Context) -> term()
cache_key(Context) ->
    {Context#context.user_id, Context#context.acl}.


%% @doc Return the id of the current user.
user(#context{user_id=UserId}) ->
	UserId.


%% @doc Call a function with admin privileges.
%% @spec sudo(FuncDef, #context) -> FuncResult
sudo({M,F}, Context) ->
    erlang:apply(M, F, [set_admin(Context)]);
sudo({M,F,A}, Context) ->
    erlang:apply(M, F, A ++ [set_admin(Context)]);
sudo(F, Context) when is_function(F, 1) ->
    F(set_admin(Context)).

sudo(Context) ->
    set_admin(Context).

    set_admin(#context{acl=undefined} = Context) ->
        Context#context{acl=admin, user_id=?ACL_ADMIN_USER_ID};
    set_admin(Context) ->
        Context#context{acl=admin}.


%% @doc Call a function as the anonymous user.
%% @spec anondo(FuncDef, #context) -> FuncResult
anondo({M,F}, Context) ->
    erlang:apply(M, F, [set_anonymous(Context)]);
anondo({M,F,A}, Context) ->
    erlang:apply(M, F, A ++ [set_anonymous(Context)]);
anondo(F, Context) when is_function(F, 1) ->
    F(set_anonymous(Context)).

anondo(Context) ->
    set_anonymous(Context).

    set_anonymous(Context) ->
        Context#context{acl=undefined, user_id=undefined}.



%% @doc Log the user with the id on, fill the acl field of the context
%% @spec logon(int(), #context) -> #context
logon(Id, Context) ->
	case z_notifier:first({acl_logon, Id}, Context) of
		undefined -> Context#context{acl=undefined, user_id=Id};
		#context{} = NewContext -> NewContext
	end.


%% @doc Log off, reset the acl field of the context
%% @spec logoff(#context) -> #context
logoff(Context) ->
	case z_notifier:first({acl_logoff}, Context) of
		undefined -> Context#context{user_id=undefined, acl=undefined};
		#context{} = NewContext -> NewContext
	end.

