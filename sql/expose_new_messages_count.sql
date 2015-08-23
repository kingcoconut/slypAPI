use slyp_alpha;

select count(scm.id)
from slyp_chats sc
join slyp_chat_users scu
on (sc.id = scu.slyp_chat_id)
join slyp_chat_messages scm
on (scm.slyp_chat_id = sc.id)
where scu.user_id = 2 and sc.slyp_id = 1 and scm.user_id <> 2 and scm.created_at > scu.last_read_at;
