#!/bin/tcsh
#----------------------------------------------------------------------
# Purpose:
#   To launch a query to the IRSA TAP service, producing a FITS FILE
#   This version is specifically geared up to select fields that are 
#   not corrupted in the slphotdr4 table as we failed if we selected 
#   everything.
#----------------------------------------------------------------------
# Parameters
#    $1 the name of the field  - purely to determine names of outputs
#    $2-$5 RAMIN, RAMAX, DECMIN, DECMAX - all in decimal degrees
#    $6 table name in IRSA (see irsa_tables.* or get latest versions from 
#    curl -o irsa_tables.fits "http://irsa.ipac.caltech.edu/TAP/sync?QUERY=SELECT+*+FROM+TAP_SCHEMA.tables&FORMAT=FITS"
#
#----------------------------------------------------------------------
# How to Improve:
#    The polygon is bounded by great circles, so this may not be exactly
#    what the user expects by specifying min/max limits.  Better might be
#    to use the BOX geometry but then we'd need to do some calculations in
#    the script and I couldn't be bothered.
#
#    Might be nice to have the required fields in an input parameter file? 
#    rather than hard-wired into the script
#
#    Could have an option to select FITS/VOTABLE etc.  Current a VOT format
#    version is commented out
#
#----------------------------------------------------------------------
# Author(s): 
#    Seb Oliver (University of Sussex)
#----------------------------------------------------------------------
# Date: 
#    29th November 2015 (tested with commented header)
#----------------------------------------------------------------------
# Acknowledgement: 
#    This script was produced as part of the Herschel Extragalactic 
#    Legacy Project: HELP
#    The research leading to these results has received funding from the 
#    European Union Seventh Framework Programme FP7/2007-2013/ under 
#    grant agreement no 607254.”
#    "This publication reflects only the author’s view and the European 
#     Union is not responsible for any use that may be made of the 
#     information contained therein.” 
#----------------------------------------------------------------------
# end of header
#----------------------------------------------------------------------

set field=$1
set ramin=$2
set ramax=$3
set decmin=$4
set decmax=$5
set table=$6

set id=$field"_"$table

# FITS FORMAT
 curl  --stderr $id.log -v "http://irsa.ipac.caltech.edu/TAP/async?QUERY=SELECT+objid,crowded,ra,dec,nmatches,nreject,nbands,i1_fluxtype,i2_fluxtype,i3_fluxtype,m1_fluxtype,i1_f_ap2,i1_df_ap1,i2_f_ap2,i2_df_ap1,i3_f_ap2,i3_df_ap1,i4_f_ap2,i4_df_ap1,m1_f_psf,m1_df_psf,i1_meannoise,i2_meannoise,i3_meannoise,i4_meannoise,i1_coverage,i2_coverage,i3_coverage,i4_coverage+FROM+"$table"+WHERE+CONTAINS(POINT('J2000',ra,dec),POLYGON('J2000',"$ramin","$decmin","$ramax","$decmin","$ramax","$decmax","$ramin","$decmax"))=1&FORMAT=FITS&PHASE=RUN" 

# VOT FORMAT
# curl  --stderr $id.log -v "http://irsa.ipac.caltech.edu/TAP/async?QUERY=SELECT+*+FROM+"$table"+WHERE+CONTAINS(POINT('J2000',ra,dec),POLYGON('J2000',"$ramin","$decmin","$ramax","$decmin","$ramax","$decmax","$ramin","$decmax"))=1&PHASE=RUN" 


echo $id >> HELP_tap_irsa.urls
grep Location $id.log   >> HELP_tap_irsa.urls
echo "-----------------------" >> HELP_tap_irsa.urls

