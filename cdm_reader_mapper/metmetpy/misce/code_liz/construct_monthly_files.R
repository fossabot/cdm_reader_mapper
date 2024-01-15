args = commandArgs(trailingOnly=TRUE)

# arguments are start and stop years
# 3rd argument is whether to apply info from gap fillling
# if "use_gaps" then read in output of gap filling and write to R3MONTHLY
# if "no_gaps" then no gap filling and write to R3MONTHLY_ORIG

# arguments are start and end year and switch whether to read in gap info (use_gaps/no_gaps)

#source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/read_rdsfiles.R")
#source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/get_iso_uid.R")
#source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/get_dup_uids.R")
#source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/get_merge_uids.R")
#source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/classify_ids.R")

source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/get_dup_uid.R")
source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/reformat_ids.R")
source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/correct_ids.R")
source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/check_regex.R") # gives classify_ids function
source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/add_date.R")

print.mess <- FALSE  # print diagnostics
options(warn=1)      # print warnings as soon as they occur

 #----------------------------------------------------------------------------------
 #  SHIP TRACKING INPUT
 #----------------------------------------------------------------------------------

if ( is.na(args[1]) | is.null (args[1]) ) {
 cat('running from',my.start,'to',my.end,'with',gap.switch,'\n')
} else {
 my.start <- args[1]
 my.end <- args[2]
 gap.switch <- args[3]
}

if ( gap.switch == "use_gaps" ) {
 base.outdir <- "/pgdata/eck/R3MONTHLY/"
} else if (gap.switch == "no_gaps" ) {
 base.outdir <- "/pgdata/eck/R3MONTHLY_ORIG/"
} else {
 # defaut is to use gaps
 base.outdir <- "/pgdata/eck/R3MONTHLY/"
}

print(paste("output to",base.outdir))

# check expected directory structure is there
if (!dir.exists(paste0(base.outdir,"IDBAD"))) { dir.create(paste0(base.outdir,"IDBAD")) }
if (!dir.exists(paste0(base.outdir,"BYDECK"))) { dir.create(paste0(base.outdir,"BYDECK")) }
if (!dir.exists(paste0(base.outdir,"IDGEN"))) { dir.create(paste0(base.outdir,"IDGEN")) }
if (!dir.exists(paste0(base.outdir,"IDMISS"))) { dir.create(paste0(base.outdir,"IDMISS")) }
if (!dir.exists(paste0(base.outdir,"IDOK"))) { dir.create(paste0(base.outdir,"IDOK")) }
if (!dir.exists(paste0(base.outdir,"SUS"))) { dir.create(paste0(base.outdir,"SUS")) }
if (!dir.exists(paste0(base.outdir,"REMOVED_DUPS"))) { dir.create(paste0(base.outdir,"REMOVED_DUPS")) }


# this used to remove files across directories for month being processed
flist.alldecks<-list.files(path=paste0(base.outdir,"BYDECK",recursive=T,full.names=TRUE))

for (year in my.start:my.end ) {
print('=====================')
print(year)
print('=====================')
for ( month in 1:12 ) {
#print('=====================')
if ( month >=10 ) {
 fn <- paste0("/noc/mpoc/scratch/surfacemet/ICOADS3_0/RDA/ICOADS_R3.0.0_",year,"-",month,".Rda")
} else {
 fn <- paste0("/noc/mpoc/scratch/surfacemet/ICOADS3_0/RDA/ICOADS_R3.0.0_",year,"-0",month,".Rda")
}
if ( year >= 2015 ) { fn <- gsub("3.0.0","3.0.1",fn) }
print(fn)
df<- readRDS(fn)

#----------------------------------------------------------------------------------
# correct PTs, then select
#----------------------------------------------------------------------------------
# these dcks have missing PT and are thought to be ships
ship.pt <- c(128,150,151,152,155,156,192,201,246,201,246,255,875,897,899)
df$pt <- ifelse ( is.na(df$pt) & df$dck %in% ship.pt, 5, df$pt )
# ship data in buoy deck
df$pt <- ifelse ( is.na(df$pt) & df$dck ==993, 5, df$pt )
other.pt <- c(714, 793, 794, 797, 883, 896, 993, 994)
# other types of data, discard for now
df <- subset(df,dck!=995)  # CMAN
df$pt <- ifelse ( is.na(df$pt) & df$dck %in% other.pt, 99, df$pt )
df$pt <- ifelse ( df$pt==5 & df$dck %in% other.pt, 99, df$pt )
df$pt <- ifelse ( df$pt==4 & df$dck %in% other.pt, 99, df$pt )
df <- subset(df, is.na(pt) | pt <= 5 | pt == 9 | pt == 10 | pt == 11 | pt == 12 | pt == 17 )
df <- subset(df, (id != "PLAT" & id != "BUOY" & id != "RIGG" & id != "BOUY") | is.na(id) )
df <- df[!grepl("RIGG",df$id),]
df <- df[!grepl("PLAT",df$id),]
df <- subset(df, !(is.na(id) & dck==700)) # these are drifters
idt<-df$id
idt<-gsub('[0-9]',"N",idt)
df <- subset(df, !(idt=="NNNNN" & dck==700 & sid == 147 & pt == 5)) # these seem to be buoys
idt<-df$id
idt<-gsub('[0-9]',"N",idt)
df <- subset(df, !(idt=="NNNNN" & dck==892 & sid == 29 & pt == 5)) # these seem to be buoys

# at this point we should only have ship data

#cat('about to reformat','\n')
#readline(prompt="Press [enter] to continue")

df<-reformat_ids(df)
#df<-classify_ids(df)
df<-correct_ids(df)  # this does more major correction, joining etc.
df<-classify_ids(df)

if ( gap.switch != "no_gaps" ) {
  source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/get_gap_uids.R")
  if ( !is.null(gapdata) ) {
    gapdata<-subset(gapdata,uid %in% df$uid)
    df<-merge(df,gapdata[,c("uid","newid")],by=c("uid"),all.x=T)
    df$idtype<-ifelse(!is.na(df$newid),1,df$idtype)
    df$qcid<-ifelse(!is.na(df$newid),df$newid,df$qcid)
    df$newid<-NULL
  }
}

#cat('about to classify','\n')
#readline(prompt="Press [enter] to continue")
#cat('done classify','\n')
#readline(prompt="Press [enter] to continue")

df2<-add_date(df)
df2$recordnumber<-df2$uid
df2$obsid<-df2$uid
df2$track.id<-df2$qcid

datain<-df2
  names.in <- c("obsid","uid","yr","mo","dy","hr","lon","lat","vs",
                  "ds","sst","slp","at","dpt","w","d","n","vv","ww","w1",
                  "c1","c1m","recordnumber","pt","dck","qcpt","idflag",
                  "dupflag","dckpriority","ii","sid","si","sim","id",
                  "track.id","qcid","date","idtype")
  datain2<-datain
  datain2[, setdiff(names.in, names(datain2))] <- NA
  datain2$obsid<-datain2$uid
  datain2$recordnumber<-datain2$uid
  datain2$idflag<-datain2$idtok
  datain2$qcpt<-datain2$pt
  datain2$track.id<-datain2$qcid

  datain.ship <- datain2[,names.in]
  rm(datain2)


#----------------------------------------------------------------------------------
# longitudes need to be -180:180
#----------------------------------------------------------------------------------
  datain.ship$lon[which(datain.ship$lon>=180)]<-datain.ship$lon[which(datain.ship$lon>=180)]-360
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
# flag duplicates
#----------------------------------------------------------------------------------

  #source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/apply_dups.R")
  #uids<-apply_dups(datain.ship)
  uids<-get_dup_uid(datain.ship)
  #datain.dup<-subset(datain.ship, uid %in% uids)
  #datain.ship<-subset(datain.ship, !(uid %in% uids))
  #datain.ship$idtype[which(datain.ship$uid %in% uids)] <- "5"
  datain.ship$idtype[which(uids$dup)] <- "5"
  if ( "newid" %in% names(datain.ship)){
   datain.ship$qcid<-ifelse(!is.na(datain.ship$newid,datain.ship$newid,datain.ship$qcid))
   datain.ship$newid<-NULL
  }
  datain.ship$idtype[grepl("TEST",datain.ship$id)] <- "5"
  datain.ship$idtype[grepl("CONTEST",datain.ship$id)] <- "1"
  datain.ship$idtype[grepl("TESTA-NL",datain.ship$qcid)] <- "1"
  datain.ship$idtype<-ifelse ( datain.ship$dck == 233 & datain.ship$lat == 0, "5", datain.ship$idtype)
  datain.ship$idtype<-ifelse ( datain.ship$dck == 233 & datain.ship$lon == 0, "5", datain.ship$idtype)
  datain.ship$idtype<-ifelse ( datain.ship$dck == 233 & datain.ship$lon == (-180), "5", datain.ship$idtype)
  # keep only qcids that are valid types, after gaps only
  if ( gap.switch == "use_gaps" ) {
    datain.ship$qcid<-ifelse(datain.ship$idtype==1,datain.ship$qcid,NA)
  }

  if(length(uids$dup)>0){
    #YRMO <- split(datain.dup, data.frame(datain.dup$yr, datain.dup$mo), drop=TRUE)
    uids<-uids[which(uids$dup),]
    if ( nrow(uids) > 0 ) {
    YRMO <- split(uids, data.frame(uids$yr, uids$mo), drop=TRUE)
    filenames <- paste(base.outdir,"REMOVED_DUPS/",names(YRMO), ".Rda",sep="")
    jj<-mapply(saveRDS, YRMO, file = filenames )
    }
  }

#----------------------------------------------------------------------------------
# write input data to R3MONTHLY monthly files
#----------------------------------------------------------------------------------

if(length(datain.ship$id)>0){
        YRMO <- split(datain.ship, data.frame(datain.ship$yr, datain.ship$mo), drop=TRUE)
        filenames <- paste(base.outdir,names(YRMO), ".Rda",sep="")
        print(filenames)
        jj<-mapply(saveRDS, YRMO, file = filenames )
}


#=======================================================
# split by ID type (OK, invalid, generic, missing)
#=======================================================
 datain.split <- split(datain.ship,datain.ship$idtype)
 check <- names(datain.split)
 datain.valid <- NULL
 datain.bad <- NULL
 datain.gen <- NULL
 datain.miss <- NULL
 datain.sus <- NULL
 if ( "1" %in% check ) {datain.valid <- datain.split[["1"]]}
 if ( "2" %in% check ) {datain.bad <- datain.split[["2"]]}
 if ( "3" %in% check ) {datain.gen <- datain.split[["3"]]}
 if ( "4" %in% check ) {datain.miss <- datain.split[["4"]]}
 if ( "5" %in% check ) {datain.sus <- datain.split[["5"]]}
#=======================================================
# remove old valid files for year and month
fn <- paste(base.outdir,"IDOK/",year,".",month,".Rda",sep="")
if (file.exists(fn)) file.remove(fn)
# remove old generic files for year and month
fn <- paste(base.outdir,"IDGEN/",year,".",month,".Rda",sep="")
if (file.exists(fn)) file.remove(fn)
# remove old missing files for year and month
fn <- paste(base.outdir,"IDMISS/",year,".",month,".Rda",sep="")
if (file.exists(fn)) file.remove(fn)
# remove old bad ID files for year and month
fn <- paste(base.outdir,"IDBAD/",year,".",month,".Rda",sep="")
if (file.exists(fn)) file.remove(fn)
fn <- paste(base.outdir,"SUS/",year,".",month,".Rda",sep="")
if (file.exists(fn)) file.remove(fn)

if(length(datain.valid$id)>0){
        YRMO <- split(datain.valid, data.frame(datain.valid$yr, datain.valid$mo), drop=TRUE)
        filenames <- paste(base.outdir,"IDOK/",names(YRMO), ".Rda",sep="")
        jj<-mapply(saveRDS, YRMO, file = filenames )
}

#=======================================================
# data with generic IDs

if(length(datain.gen$id)>0){
        YRMO <- split(datain.gen, data.frame(datain.gen$yr, datain.gen$mo), drop=TRUE)
        filenames <- paste(base.outdir,"IDGEN/",names(YRMO), ".Rda",sep="")
        jj<-mapply(saveRDS, YRMO, file = filenames )
} else {
print('no generic ids')
}

#=======================================================
# missing ID data

if(length(datain.miss$id)>0){
        YRMO <- split(datain.miss, data.frame(datain.miss$yr, datain.miss$mo), drop=TRUE)
        filenames <- paste(base.outdir,"IDMISS/",names(YRMO), ".Rda",sep="")
        jj<-mapply(saveRDS, YRMO, file = filenames )
} else {
print('no missing ids')
}

#=======================================================
# corrupted ID data

if(length(datain.bad$id)>0){
        YRMO <- split(datain.bad, data.frame(datain.bad$yr, datain.bad$mo), drop=TRUE)
        filenames <- paste(base.outdir,"IDBAD/",names(YRMO), ".Rda",sep="")
        jj<-mapply(saveRDS, YRMO, file = filenames )
} else {
print('no corrupt ids')
}
#=======================================================
# suspect data (dups, iso etc.)

if(length(datain.sus$id)>0){
        YRMO <- split(datain.sus, data.frame(datain.sus$yr, datain.sus$mo), drop=TRUE)
        filenames <- paste(base.outdir,"SUS/",names(YRMO), ".Rda",sep="")
        jj<-mapply(saveRDS, YRMO, file = filenames )
} else {
print('no suspect data')
}
#=======================================================

####### write out data by deck and id type/quality

  #----------------------------------------------------------------------------------
  # write data to R3MONTHLY monthly files, dck directory
  #----------------------------------------------------------------------------------

  df<-readRDS(paste0(base.outdir ,year,".",month,".Rda"))

  fn <- paste(year,month,"Rda",sep=".")
  flist.thismonth<-flist.alldecks[grep(fn,flist.alldecks)]
  file.remove(flist.thismonth)

  if(length(df$id)>0){
    bydck <- split(df,df$dck,drop=TRUE)
    print(paste(c("Decks =",names(bydck)),collapse=" "))
    #maindir <- "/noc/mpoc/surface_data/TRACKING/FinalTrack/R3MONTHLY/BYDECK"
    maindir <- paste0(base.outdir,"BYDECK")
    for ( dcks in names(bydck) ) {
      dckdir <- paste0("dck",dcks)
      ifelse(!dir.exists(file.path(maindir, dckdir)), dir.create(file.path(maindir, dckdir),recursive=T), FALSE)
    }
    filenames <- paste(base.outdir,"BYDECK/dck",names(bydck),"/",year,".",month,".Rda",sep="")
    jj<-mapply(saveRDS, bydck, file = filenames )
  }

  #----------------------------------------------------------------------------------
  # write IDOK data to R3MONTHLY monthly files, dck directory
  #----------------------------------------------------------------------------------

  in.file <- paste0(base.outdir,"IDOK/",year,".",month,".Rda")
  if(file.exists(in.file)){
   df<-readRDS(in.file)

   print(table(df$dck,df$sid))

   if(length(df$id)>0){
     bydck <- split(df,df$dck,drop=TRUE)
     #maindir <- "/noc/mpoc/surface_data/TRACKING/FinalTrack/R3MONTHLY/BYDECK/IDOK"
     maindir <- paste0(base.outdir,"BYDECK/IDOK")
     for ( dcks in names(bydck) ) {
       dckdir <- paste0("dck",dcks)
       ifelse(!dir.exists(file.path(maindir, dckdir)), dir.create(file.path(maindir, dckdir),recursive=T), FALSE)
     }
     filenames <- paste(base.outdir,"BYDECK/IDOK/dck",names(bydck),"/",year,".",month,".Rda",sep="")
     jj<-mapply(saveRDS, bydck, file = filenames )
   }
  }


  #----------------------------------------------------------------------------------
  # write IDBAD data to R3MONTHLY monthly files, dck directory
  #----------------------------------------------------------------------------------

  in.file <- paste0(base.outdir,"IDBAD/",year,".",month,".Rda")
  if(file.exists(in.file)){
   df<-readRDS(in.file)

   if(length(df$id)>0){
     bydck <- split(df,df$dck,drop=TRUE)
     #maindir <- "/noc/mpoc/surface_data/TRACKING/FinalTrack/R3MONTHLY/BYDECK/IDBAD"
     maindir <- paste0(base.outdir,"BYDECK/IDBAD")
     for ( dcks in names(bydck) ) {
       dckdir <- paste0("dck",dcks)
       ifelse(!dir.exists(file.path(maindir, dckdir)), dir.create(file.path(maindir, dckdir),recursive=T), FALSE)
     }
     filenames <- paste(base.outdir,"BYDECK/IDBAD/dck",names(bydck),"/",year,".",month,".Rda",sep="")
     jj<-mapply(saveRDS, bydck, file = filenames )
   }
  }

  #----------------------------------------------------------------------------------
  # write IDMISS data to R3MONTHLY monthly files, dck directory
  #----------------------------------------------------------------------------------

  in.file <- paste0(base.outdir,"IDMISS/",year,".",month,".Rda")
  if(file.exists(in.file)){
   df<-readRDS(in.file)

   if(length(df$id)>0){
     bydck <- split(df,df$dck,drop=TRUE)
     #maindir <- "/noc/mpoc/surface_data/TRACKING/FinalTrack/R3MONTHLY/BYDECK/IDMISS"
     maindir <- paste0(base.outdir,"BYDECK/IDMISS")
     for ( dcks in names(bydck) ) {
       dckdir <- paste0("dck",dcks)
       ifelse(!dir.exists(file.path(maindir, dckdir)), dir.create(file.path(maindir, dckdir),recursive=T), FALSE)
     }
     filenames <- paste(base.outdir,"BYDECK/IDMISS/dck",names(bydck),"/",year,".",month,".Rda",sep="")
     jj<-mapply(saveRDS, bydck, file = filenames )
   }
  }

  #----------------------------------------------------------------------------------
  # write IDGEN data to R3MONTHLY monthly files, dck directory
  #----------------------------------------------------------------------------------

  in.file <- paste0(base.outdir,"IDGEN/",year,".",month,".Rda")

   if(file.exists(in.file)){
    df<-readRDS(in.file)

   if(length(df$id)>0){
     bydck <- split(df,df$dck,drop=TRUE)
     #maindir <- "/noc/mpoc/surface_data/TRACKING/FinalTrack/R3MONTHLY/BYDECK/IDGEN"
     maindir <- paste0(base.outdir,"BYDECK/IDGEN")
     for ( dcks in names(bydck) ) {
       dckdir <- paste0("dck",dcks)
       ifelse(!dir.exists(file.path(maindir, dckdir)), dir.create(file.path(maindir, dckdir),recursive=T), FALSE)
     }
     filenames <- paste(base.outdir,"BYDECK/IDGEN/dck",names(bydck),"/",year,".",month,".Rda",sep="")
     jj<-mapply(saveRDS, bydck, file = filenames )
   }
  }

  #----------------------------------------------------------------------------------
  # write SUS data to R3MONTHLY monthly files, dck directory
  #----------------------------------------------------------------------------------

  in.file <- paste0(base.outdir,"SUS/",year,".",month,".Rda")

   if(file.exists(in.file)){
    df<-readRDS(in.file)

   if(length(df$id)>0){
     bydck <- split(df,df$dck,drop=TRUE)
     #maindir <- "/noc/mpoc/surface_data/TRACKING/FinalTrack/R3MONTHLY/BYDECK/IDGEN"
     maindir <- paste0(base.outdir,"BYDECK/SUS")
     for ( dcks in names(bydck) ) {
       dckdir <- paste0("dck",dcks)
       ifelse(!dir.exists(file.path(maindir, dckdir)), dir.create(file.path(maindir, dckdir),recursive=T), FALSE)
     }
     filenames <- paste(base.outdir,"BYDECK/SUS/dck",names(bydck),"/",year,".",month,".Rda",sep="")
     jj<-mapply(saveRDS, bydck, file = filenames )
   }
  }

#readline(prompt="Press [enter] to continue")
} # end loop over months
} # end loop over years

print("empty directories")
system("find /pgdata/eck/R3MONTHLY_ORIG/BYDECK/ -type d -empty -print")
