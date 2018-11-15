// I just had a request to list all "used" infoobjects that are loading in our solution's flows
// I have createted this to list it for all solutions
// Solution is identified by process chain catalog, columns are quite obvious

select
    comp_text as "CHAIN_FOLDER",
    count (distinct chain_id) as "Chains_Count",
    count(distinct dtp.dtp) as dtp_count,
    dtp.tgt as "IOBJ_NAME",
    to_date(to_varchar(to_bigint(round(max(endtimestamp),-6,ROUND_DOWN))),'YYYYMMDDHHMISS') as last_loaded_in_chain,
    to_date(to_varchar(to_bigint(round(max(rq.TSTMP_FINISH),-6,ROUND_DOWN))),'YYYYMMDDHHMISS') as last_loaded_in_dtp
from

RSBKDTP dtp
join RSBKREQUEST rq on rq.dtp = dtp.dtp
    and rq.TSTMP_START > 20170000000000.0000000
left outer join
   (   select
        l.variante as DTP,
        lc.chain_id,
        ct.TXTLG comp_text,
        endtimestamp
    from
        RSPCPROCESSLOG l
        join RSPCLOGCHAIN lc
            on lc.LOG_ID = l.LOG_ID
        join RSPCCHAINATTR ca on
            ca.CHAIN_ID = lc.CHAIN_ID
        join RSCOMPTLOGOT ct on
            ct.applnm = ca.applnm
    where
        l.type = 'DTP_LOAD'
        and endtimestamp   <> 0
        and starttimestamp > 20170000000000.0000000
        ) logs
   on dtp.dtp = logs.dtp
where
    dtp.objvers = 'A'
    and dtp.tgttp like 'IOBJ_'
    and dtp.tgt like '0%'
group by
    dtp.tgt,
    comp_text
order by
    comp_text,
    dtp_count desc
