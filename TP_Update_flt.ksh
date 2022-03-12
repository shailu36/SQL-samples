#!/bin/ksh
###################################################################
# Log Function
###################################################################
Log()
{
        print "$scriptname:     `date +%Y%m%d.%H%M%S`: $@" >> $LOGFile
}

############################################################################
##
############################################################################
Cmd=$0
BASE=~/tp
scriptname=${0##/*/}
log=${scriptname%.ksh}                    # logfile name = script name
STAMP=$(date +%Y%m%d.%H%M%S)
stampName="$log.$STAMP"
LOG=${BASE}/logs
LOGFile=$LOG/$stampName.log
HostName=`hostname`

Data=${Data:-"$BASE/data"}

. /home/tpuser01/tp/bin/app_profile.ksh

if [ "$lifecycle" = "PR" ]
then
	DistributionCC="-c _318fc8@homedepot.com"
	Distribution=TMS_RTS@homedepot.com
else
	DistributionCC=""
	Distribution="TMS_RTS@homedepot.com"
fi

Log "Connect to $db"
db2 connect to $db > /dev/null

###########Weekly Capacity update for 64 FLT for service_level_id = matrix and disaster matrix ##########
Cnt=`db2 -x "select count(distinct a.lane_id) \
from  \
	comb_lane a \
	left outer join comb_lane_dtl b on a.lane_id = b.lane_id \
	left outer join carrier_code c on b.carrier_id = c.carrier_id \
	left outer join rating_lane_dtl_rate d on \
		d.rating_lane_dtl_seq = b.lane_dtl_seq and d.lane_id = a.lane_id \
	left outer join surge_capacity e on \
		e.rg_lane_dtl_seq = b.lane_dtl_seq and b.lane_id = e.lane_id \
where  \
	b.expiration_dt > current timestamp \
	and b.lane_dtl_status = 0              \
	and c.carrier_code <> 'REP-X' \
	and b.weekly_capacity < 100 and b.mot_id = 64 and b.service_level_id in (2,265) \
	with ur"`

if [[ $Cnt -gt 0 ]]
then
	db2 -x "select distinct a.lane_id \
	from  \
		comb_lane a \
		left outer join comb_lane_dtl b on a.lane_id = b.lane_id \
		left outer join carrier_code c on b.carrier_id = c.carrier_id \
		left outer join rating_lane_dtl_rate d on \
			d.rating_lane_dtl_seq = b.lane_dtl_seq and d.lane_id = a.lane_id \
		left outer join surge_capacity e on \
			e.rg_lane_dtl_seq = b.lane_dtl_seq and b.lane_id = e.lane_id \
	where  \
		b.expiration_dt > current timestamp \
		and b.lane_dtl_status = 0              \
		and c.carrier_code <> 'REP-X' \
		and b.weekly_capacity < 100 and b.mot_id = 64 and b.service_level_id in (2,265) \
		with ur" > CapLaneID.dat
	
	while read CapLaneID
	do
		CapLaneDtl=`db2 -x "select b.lane_dtl_seq \
			from  \
			comb_lane a \
			left outer join comb_lane_dtl b on a.lane_id = b.lane_id \
			left outer join carrier_code c on b.carrier_id = c.carrier_id \
			left outer join rating_lane_dtl_rate d on \
				d.rating_lane_dtl_seq = b.lane_dtl_seq and d.lane_id = a.lane_id \
			left outer join surge_capacity e on \
				e.rg_lane_dtl_seq = b.lane_dtl_seq and b.lane_id = e.lane_id \
			where  \
			a.lane_id = ${CapLaneID} \
			and b.expiration_dt > current timestamp \
			and b.lane_dtl_status = 0              \
			and c.carrier_code <> 'REP-X' \
			and b.weekly_capacity < 100 and b.mot_id = 64 and b.service_level_id in (2,265) \
			with ur"`
	
		WCCapLaneDtl=`echo $CapLaneDtl | sed "s/ /, /g"`
	        Log "CapLaneID - ${CapLaneID}"
	        Log "CapLaneDtl - ${CapLaneDtl}"
		##-------CAPACITY UPDATE---------
		db2 -x "Update comb_lane_dtl set weekly_capacity = (weekly_capacity + 100) \
			where LANE_ID = ${CapLaneID} \
			and LANE_DTL_SEQ in (${WCCapLaneDtl})"
	
	done < CapLaneID.dat
else
	Log "No CapLanes to process for matrix or disaster matrix"
fi

Cnt=`db2 -x "select count(distinct a.lane_id) \
from  \
        comb_lane a \
        left outer join comb_lane_dtl b on a.lane_id = b.lane_id \
        left outer join carrier_code c on b.carrier_id = c.carrier_id \
        left outer join rating_lane_dtl_rate d on \
                d.rating_lane_dtl_seq = b.lane_dtl_seq and d.lane_id = a.lane_id \
        left outer join surge_capacity e on \
                e.rg_lane_dtl_seq = b.lane_dtl_seq and b.lane_id = e.lane_id \
where  \
        b.expiration_dt > current timestamp \
        and b.lane_dtl_status = 0              \
        and c.carrier_code <> 'REP-X' \
        and b.weekly_capacity > 0 and b.weekly_capacity < 100 and b.mot_id = 64 and b.service_level_id =1 \
        with ur"`

if [[ $Cnt -gt 0 ]]
then
        db2 -x "select distinct a.lane_id \
        from  \
                comb_lane a \
                left outer join comb_lane_dtl b on a.lane_id = b.lane_id \
                left outer join carrier_code c on b.carrier_id = c.carrier_id \
                left outer join rating_lane_dtl_rate d on \
                        d.rating_lane_dtl_seq = b.lane_dtl_seq and d.lane_id = a.lane_id \
                left outer join surge_capacity e on \
                        e.rg_lane_dtl_seq = b.lane_dtl_seq and b.lane_id = e.lane_id \
        where  \
                b.expiration_dt > current timestamp \
                and b.lane_dtl_status = 0              \
                and c.carrier_code <> 'REP-X' \
                and b.weekly_capacity > 0 and b.weekly_capacity < 100 and b.mot_id = 64 and b.service_level_id =1 \
                with ur"`

if [[ $Cnt -gt 0 ]]
then
        db2 -x "select distinct a.lane_id \
        from  \
                comb_lane a \
                left outer join comb_lane_dtl b on a.lane_id = b.lane_id \
                left outer join carrier_code c on b.carrier_id = c.carrier_id \
                left outer join rating_lane_dtl_rate d on \
                        d.rating_lane_dtl_seq = b.lane_dtl_seq and d.lane_id = a.lane_id \
                left outer join surge_capacity e on \
                        e.rg_lane_dtl_seq = b.lane_dtl_seq and b.lane_id = e.lane_id \
        where  \
                b.expiration_dt > current timestamp \
                and b.lane_dtl_status = 0              \
                and c.carrier_code <> 'REP-X' \
                and b.weekly_capacity > 0 and b.weekly_capacity < 100 and b.mot_id = 64 and b.service_level_id =1 \
                with ur" > CapLaneID1.dat

        while read CapLaneID1
        do
                CapLaneDtl=`db2 -x "select b.lane_dtl_seq \
                        from  \
                        comb_lane a \
                        left outer join comb_lane_dtl b on a.lane_id = b.lane_id \
                        left outer join carrier_code c on b.carrier_id = c.carrier_id \
                        left outer join rating_lane_dtl_rate d on \
                                d.rating_lane_dtl_seq = b.lane_dtl_seq and d.lane_id = a.lane_id \
                        left outer join surge_capacity e on \
                                e.rg_lane_dtl_seq = b.lane_dtl_seq and b.lane_id = e.lane_id \
                        where  \
                        a.lane_id = ${CapLaneID} \
                        and b.expiration_dt > current timestamp \
                        and b.lane_dtl_status = 0              \
                        and c.carrier_code <> 'REP-X' \
                        and b.weekly_capacity > 0 and b.weekly_capacity < 100 and b.mot_id = 64 and b.service_level_id =1 \
                         with ur"`

                WCCapLaneDtl=`echo $CapLaneDtl1 | sed "s/ /, /g"`
                Log "CapLaneID - ${CapLaneID1}"
                Log "CapLaneDtl - ${CapLaneDtl}"
                ##-------CAPACITY UPDATE---------
                db2 -x "Update comb_lane_dtl set weekly_capacity = (weekly_capacity + 100) \
                        where LANE_ID = ${CapLaneID1} \
                        and LANE_DTL_SEQ in (${WCCapLaneDtl})"

        done < CapLaneID1.dat
else
        Log "No CapLanes to process for bid"
fi
fi


db2 disconnect $db > /dev/null

cat $LOGFile | mail -s "CAPACITY Update for FLT bid log" $DistributionCC $Distribution
