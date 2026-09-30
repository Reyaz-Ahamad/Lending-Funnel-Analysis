
drop table if exists #mis;
drop table if exists #data;

select *
into #mis
from mis.dbo.mpokket with (nolock)

select
    try_cast(registered_since_timestamp_ist as date)    as activity_date,
    external_user_id,

    case when registered_since_timestamp_ist is not null
         then external_user_id end                      as total_registered,

    case when dob is not null
          or  residence_city is not null
         then external_user_id end                      as total_info_given,

    case when aadhar_given = '1' and pan_given='1'
         then external_user_id end                      as kyc_done,

    case when student_doc_given = '1'
          or  sib_doc_given     = '1'
          or  sic_doc_given     = '1'
          or  se_doc_given      = '1'
         then external_user_id end                      as doc_given,

    case when complete_approval_timestamp_ist is not null
          or  loan_disbursed_timestamp_ist    is not null
          or  rejected_by_creditshield        = '1'
         then external_user_id end                      as total_decision_taken,

    case when complete_approval_timestamp_ist is not null
         then external_user_id end                      as approval,

    case when loan_disbursed_timestamp_ist is not null
         then external_user_id end                      as disbursal

into #data
from #mis;


with approval as (
    select
        cast(complete_approval_timestamp_ist as date)   as activity_date,
        count(distinct external_user_id)                as approval
    from  #mis
    where complete_approval_timestamp_ist is not null
    group by cast(complete_approval_timestamp_ist as date)
),

disbursal as (
    select
        cast(loan_disbursed_timestamp_ist as date)      as activity_date,
        count(distinct external_user_id)                as disbursal
    from  #mis
    where loan_disbursed_timestamp_ist is not null
    group by cast(loan_disbursed_timestamp_ist as date)
),

final_base as (
    select
        d.activity_date,
        count(distinct d.total_registered)              as registered,
  count(distinct d.kyc_done)                      as kyc_done,
        count(distinct d.total_info_given)              as info_given,
        count(distinct d.doc_given)                     as doc_given,
        count(distinct d.total_decision_taken)          as decision_taken,
        count(distinct d.approval)                      as approval,
        count(distinct d.disbursal)                     as disbursal,
        isnull(a.approval,   0)                         as mtd_approval,
        isnull(ds.disbursal, 0)                         as mtd_disbursal
    from      #data    d
    left join approval  a  on d.activity_date = a.activity_date
    left join disbursal ds on d.activity_date = ds.activity_date
    where d.activity_date >= '2026-04-01'
    group by
        d.activity_date,
        a.approval,        
        ds.disbursal
),


final_result as
(
    select 
        activity_date, 
        registered, 
        kyc_done, 
        info_given, 
        doc_given, 
        decision_taken, 
        approval, 
        disbursal, 
        mtd_approval, 
        mtd_disbursal
    from final_base 
    where activity_date > eomonth(cast(getdate() as date), -1)
)

-- daily data
select 
    cast(activity_date as varchar)as activity_date, 
    registered, 
    kyc_done, 
    info_given, 
    doc_given, 
    decision_taken, 
    approval, 
    mtd_approval, 
    disbursal, 
    mtd_disbursal,

    concat(cast(round((kyc_done * 100.0) / nullif(registered, 0), 1) as decimal(10,1)), '%') as [kyc%], 
    concat(cast(round((info_given * 100.0) / nullif(kyc_done, 0), 1) as decimal(10,1)), '%') as [info%], 
    concat(cast(round((doc_given * 100.0) / nullif(info_given, 0), 1) as decimal(10,1)), '%') as [doc%], 
    concat(cast(round((decision_taken * 100.0) / nullif(doc_given, 0), 1) as decimal(10,1)), '%') as [decision%], 
    concat(cast(round((approval * 100.0) / nullif(decision_taken, 0), 1) as decimal(10,1)), '%') as [approval%], 
    concat(cast(round((mtd_approval * 100.0) / nullif(approval, 0), 1) as decimal(10,1)), '%') as [mtd_approval%'],   
    concat(cast(round((disbursal * 100.0) / nullif(mtd_approval, 0), 1) as decimal(10,1)), '%') as [disbursal%]


from final_result

union all

-- total
select 

    'total' as activity_date,

    sum(registered)       as registered,
    sum(kyc_done)         as kyc_done,
    sum(info_given)       as info_given,
    sum(doc_given)        as doc_given,
    sum(decision_taken)   as decision_taken,
    sum(approval)         as approval,
    sum(disbursal)        as disbursal,
    sum(mtd_approval)     as mtd_approval,
    sum(mtd_disbursal)    as mtd_disbursal,

    concat(cast(round(sum(kyc_done) * 100.0 / nullif(sum(registered), 0), 1) as decimal(10,1)), '%') as [kyc%],
    concat(cast(round(sum(info_given) * 100.0 / nullif(sum(kyc_done), 0), 1) as decimal(10,1)), '%') as [info%],
    concat(cast(round(sum(doc_given) * 100.0 / nullif(sum(info_given), 0), 1) as decimal(10,1)), '%') as [doc%],
    concat(cast(round(sum(decision_taken) * 100.0 / nullif(sum(doc_given), 0), 1) as decimal(10,1)), '%') as [decision%],
    concat(cast(round(sum(approval) * 100.0 / nullif(sum(decision_taken), 0), 1) as decimal(10,1)), '%') as [approval%],
    concat(cast(round(sum(mtd_approval) * 100.0 / nullif(sum(approval), 0), 1) as decimal(10,1)), '%') as [mtd_approval%],
    concat(cast(round(sum(disbursal) * 100.0 / nullif(sum(mtd_approval), 0), 1) as decimal(10,1)), '%') as [disbursal%]


from final_result



