use slyp_alpha;

select u.id, u.email, count(distinct scm.id)
from (
	select scu.slyp_chat_id, scu.last_read_at
    from slyp_chats sc
	join slyp_chat_users scu
	on (sc.id = scu.slyp_chat_id) 
	where scu.user_id = 2 and sc.slyp_id=1
) x
join slyp_chat_users scu
on (scu.slyp_chat_id = x.slyp_chat_id and scu.user_id <> 2)
join users u
on (scu.user_id = u.id) 
left join slyp_chat_messages scm
on (scm.user_id = u.id and scm.slyp_chat_id = x.slyp_chat_id and scm.created_at >= x.last_read_at)
group by u.id, u.email;


