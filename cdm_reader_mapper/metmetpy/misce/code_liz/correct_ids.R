
correct_ids <- function(df) {

idt<-df$id
idt<-gsub("[A-Z]","C",idt)
idt<-gsub("[a-z]","c",idt)
idt<-gsub("[0-9]","N",idt)
name_dcks <- c(702,704,246,730,701,731,721,710,247,711,734,249,248,736,245,249,761,750,146,897,705,706,707)

idt <- ifelse ( df$dck %in% name_dcks, "name", idt )

min_yr <- min(df$yr)
max_yr <- max(df$yr)

# dck 704, US MMJ, check these are still needed as this should be fixed separately
dck_start <- 1878
dck_end <- 1894
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  df$qcid <- ifelse ( df$dck == 704, ifelse( is.na(df$qcid) , "Unk_dck704", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Aboukir" , "Aboukir_B", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Achille-F" , "Achille_F", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Ben_-F-Pa" , "Ben-F-Pa", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Banafides" , "Bonafides", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "EarlDerbg" , "Earl_Derb", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Hcrcules" , "Hercules", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Hencules" , "Hercules", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "John_D-BR" , "John_D-Br", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Leopold_v" , "Leopold_V", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Martha-Da" , "Martha_Da", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Mozart_of" , "S-S-Mozar", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Patterdal" , "Pamerdale", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "Ethiopia" , "S-S-Ethopia", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "S-S-Ethio" , "S-S-Ethopia", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "William_H" , "Wm-H-Smit", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 704, ifelse( df$qcid == "William_J" , "William-J", df$qcid ), df$qcid )
}

# deck 194, GB marine, 6 digit, UK style 5 digit with leading digit, usually 1
# might want to strip leading digit later, 50% of ids only have leading digit
dck_start <- 1856
dck_end <- 1955
#if ( max_yr >= dck_start & min_yr <= dck_end ) {
#  df$qcid <- ifelse ( df$dck == 194 & nchar(trimws(df$id)) == 6, substr(df$id,1,6), df$qcid )
#  df$qcid <- ifelse ( df$dck == 194 & nchar(trimws(df$id)) == 1, trimws(df$id), df$qcid )
#}

# dck 730, CLIWOC, convert logbook ID to ship names using info from CLIWOC website
dck_start <- 1663
dck_end <- 1860
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {

  cliwoc_links<-readLines("/noc/mpoc/surface_data/TRACKING/FinalTrack/ANC_INFO/cliwoc_shipLogbookid2_1.txt")
  cliwoc_links<-iconv(cliwoc_links, to = "ASCII//TRANSLIT")

  cliwoc_logs<-substr(cliwoc_links,start=1,stop=4)
  cliwoc_names<-substr(cliwoc_links,start=5,stop=34)
  cliwoc_dup<-substr(cliwoc_links,start=65,stop=65)
  cliwoc_names<-trimws(cliwoc_names)
  cliwoc_names<-gsub(" ","XXXX",cliwoc_names)
  cliwoc_names<-gsub("[[:punct:]]","-",cliwoc_names)
  cliwoc_name<-iconv(cliwoc_names, to = "ASCII//TRANSLIT")
  cliwoc_names<-gsub("XXXX","_",cliwoc_names)

  cliwoc<-cbind(as.numeric(cliwoc_logs),cliwoc_names,cliwoc_dup)
  colnames(cliwoc)<-c("logs","names","cli_dups")

  df<-merge(df,cliwoc,by.x="id",by.y="logs",all.x=TRUE)
  df$qcid<-ifelse(df$dck==730,df$names,df$qcid)
  #df<-subset(df,cli_dups==0 | dck!=730)
  df$names<-NULL
  df$cli_dups<-NULL

}

# dck 701
# US Maury, names from list on ICOADS website: http://icoads.noaa.gov/software/transpec/maury/mauri_out
dck_start <- 1663
dck_end <- 1863
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  usmau_links<-readLines("/noc/mpoc/surface_data/TRACKING/FinalTrack/ANC_INFO/usmaury_names.txt")
  usmau_links<-iconv(usmau_links, to = "ASCII//TRANSLIT")
  usmau<-trimws(cbind(substr(usmau_links,7,14),substr(usmau_links,34,66)))
  colnames(usmau)<-c("short_names","names")
  # these names have 2 entries, choose one
  usmau <- usmau[which(usmau[,2] != "D. FERNANDO"),]
  usmau <- usmau[which(usmau[,2] != "CORAL OF NEW BEDFORD   S"),]
  usmau <- usmau[which(usmau[,2] != "GENERAL  JONES"),]
  usmau <- usmau[which(usmau[,2] != "MINERVA  SMYTH"),]
  usmau <- usmau[which(usmau[,2] != "SAMUEL ROBERTSON"),]
  usmau <- usmau[which(usmau[,2] != "THOMAS B. WALES"),]

  df<-merge(df,usmau,by.x="id",by.y="short_names",all.x=TRUE)
  df$qcid<-ifelse(df$dck==701 & !is.na(df$names),df$names,df$qcid)
  df$names<-NULL

  # corrections as suggested by Wilkinson/Wheeler - see webpage above
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "ABOUKIN" , "ABOUKIR", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "ACKBAR" , "AKBAR", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "HEROKEE" , "CHEROKEE", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "MALUBAR" , "MALABAR", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "MUTIN" , "MUTINE", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "NORTHUMBERIAND" , "NORTHUMBERLAND", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "PHEBE" , "PHOEBE", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "TENOBIA" , "ZENOBIA", df$qcid ), df$qcid )

# and this seemed wrong

  df$qcid <- ifelse ( df$dck == 701, ifelse( df$qcid == "HENRY_CALY" , "HENRY_CLAY", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 701, ifelse( df$id == "ZOE" , "ZOE", df$qcid ), df$qcid )

}

# dck 701, US Maury with missing id
dck_start <- 1663
dck_end <- 1863
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  df$qcid <- ifelse ( df$dck == 701 & df$id == "E-Z-", "E-Z-", df$qcid )
  df$qcid <- ifelse ( df$dck == 701 & is.na(df$id) & df$yr == 1850, "Unknown_701_1", df$qcid )
  df$qcid <- ifelse ( df$dck == 701 & is.na(df$id) & df$yr == 1851 & df$mo <= 2, "Unknown_701_1", df$qcid )
  df$qcid <- ifelse ( df$dck == 701 & is.na(df$id) & df$yr == 1851 & df$mo == 4, "Unknown_701_2", df$qcid )
  df$qcid <- ifelse ( df$dck == 701 & is.na(df$id) & df$yr == 1851 & df$mo == 12, "Unknown_701_3", df$qcid )
}

# dck 721 German Maury, make corrections based on extended length ids from US Maury, assign missing
dck_start <- 1851
dck_end <- 1868
#cat(min_yr,dck_start,max_yr,dck_end,'\n')
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  #cat('here','\n')
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "WILD RANG" , "WILD_RANGER", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "HIUGUENOT" , "HUGUENOT", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "HIPPOGRIF" , "HIPPOGRIFFE", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "NOR_WESTE" , "NOR_WESTER", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "NOR WESTE" , "NOR_WESTER", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "ROMANCE_O" , "ROMANCE_OF_THE_SEA", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "ROMANCE O" , "ROMANCE_OF_THE_SEA", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "GREAT_REP" , "GREAT_REPUBLIC", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "GREAT REP" , "GREAT_REPUBLIC", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "DREADNOUG" , "DREADNOUGHT", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "BLACK_HAW" , "BLACK_HAWK", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "BLACK HAW" , "BLACK_HAWK", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "ILLUSTRIO" , "ILLUSTRIOUS", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "RINGLEADE" , "RINGLEADER", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "SEA_SERPE" , "SEA_SERPENT", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721, ifelse( df$qcid == "SEA SERPE" , "SEA_SERPENT", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 721 & is.na(df$id) & df$yr < 1856, "Unknown_721_1", df$qcid )
  df$qcid <- ifelse ( df$dck == 721 & is.na(df$id) & df$yr == 1856 & df$mo <= 3, "Unknown_721_1", df$qcid )
  df$qcid <- ifelse ( df$dck == 721 & is.na(df$id) & df$yr == 1856 & df$mo >= 8, "Unknown_721_2", df$qcid )
  df$qcid <- ifelse ( df$dck == 721 & is.na(df$id) & df$yr == 1857, "Unknown_721_3", df$qcid )
  df$qcid <- ifelse ( df$dck == 721 & is.na(df$id) & df$yr == 1858, "Unknown_721_4", df$qcid )
  df$qcid <- ifelse ( df$dck == 721 & is.na(df$id) & df$yr >= 1863, "Unknown_721_5", df$qcid )
}

# separate AUSTRALIA's by deck

 idtmp<- ifelse( is.na(df$qcid),"xx",df$qcid)
 df$qcid <- ifelse ( df$dck %in% c(701,721) & idtmp == "AUSTRALIA", paste0(idtmp,"_d",df$dck),df$qcid)
 df$qcid <- ifelse ( df$dck %in% c(701,721) & idtmp == "JAMESTOWN", paste0(idtmp,"_d",df$dck),df$qcid)
 df$qcid <- ifelse ( df$dck %in% c(701,721) & idtmp == "SWORDFISH", paste0(idtmp,"_d",df$dck),df$qcid)
 df$qcid <- ifelse ( df$dck %in% c(701,721) & (idtmp == "ANN_MARIA" | idtmp == "ANN_MARI" | idtmp == "ANN MARIA"), paste0(idtmp,"_d",df$dck),df$qcid)
 df$qcid <- ifelse ( df$dck %in% c(701,721) & idtmp == "ASHBURTON", paste0(idtmp,"_d",df$dck),df$qcid)

# US MM decks 705-707
dck_start <- 1910
dck_end <- 1946
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
 # these are the new names by uid
 usmm_links <- read_trackmonth("/noc/mpoc/surface_data/TRACKING/FinalTrack/DCK_705to707uid",syr=min(df$yr),eyr=max(df$yr))
 df <- merge(df,usmm_links[,c("uid","newname")],by=c("uid"),all.x=TRUE)
 df$qcid <- ifelse ( df$dck == 705 | df$dck == 706 | df$dck == 707, df$newname, df$qcid )
 df$newname <- NULL

 df$qcid <- ifelse (df$id == "FR001544", df$id, df$qcid)
 df$qcid <- ifelse (df$id == "FR001481", df$id, df$qcid)
 df$qcid <- ifelse (df$id == "JP016438", df$id, df$qcid)
 df$qcid <- ifelse (df$id == "US155724", df$id, df$qcid)
}


# sort out sequential IDs

# dcks 192_215, 197, 216, 720 (sids 134 & 136) have sequential logbook IDs,
# read in substitutions from ANC_INFO files

dck_start <- 1868
dck_end <- 1988
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  fname <- paste0("/noc/mpoc/surface_data/TRACKING/FinalTrack/ANC_INFO/ids_to_join_720.txt")
  tosub <- read.table(fname,sep=",")
  names(tosub)<-c("id","newid")
  tosub$id<-as.character(tosub$id)
  tosub$id<-ifelse(nchar(tosub$id)==7,paste0("0",tosub$id),tosub$id)
  tosub$newid<-as.character(tosub$newid)
  tosub$newid<-ifelse(nchar(tosub$newid)==7,paste0("0",tosub$newid),tosub$newid)
  df<-merge(df,tosub,by="id",all.x=TRUE)
  df$qcid<-ifelse((df$dck==720 & (df$sid == 134 | df$sid == 136)) & !is.na(df$newid),df$newid,df$qcid)
  df$newid <- NULL
}


# dck 216, UK MDB merchant ships
dck_start <- 1935
dck_end <- 1939
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  fname <- paste0("/noc/mpoc/surface_data/TRACKING/FinalTrack/ANC_INFO/ids_to_join_216.txt")
  tosub <- read.table(fname,sep=",")
  names(tosub)<-c("id","newid")
  df<-merge(df,tosub,by="id",all.x=TRUE)
  df$qcid<-ifelse(df$dck==216 & !is.na(df$newid),df$newid,df$qcid)
  df$newid <- NULL
}

# dcks 192 & 215, German merchant data, 215 = MDB version
dck_start <- 1855
dck_end <- 1940
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  fname <- paste0("/noc/mpoc/surface_data/TRACKING/FinalTrack/ANC_INFO/ids_to_join_192_215.txt")
  tosub <- read.table(fname,sep=",")
  names(tosub)<-c("id","newid")
  tosub$id<-as.character(tosub$id)
  tosub$id<-ifelse(nchar(tosub$id)==7,paste0("0",tosub$id),tosub$id)
  tosub$newid<-as.character(tosub$newid)
  tosub$newid<-ifelse(nchar(tosub$newid)==7,paste0("0",tosub$newid),tosub$newid)
  df<-merge(df,tosub,by="id",all.x=TRUE)
  df$qcid<-ifelse((df$dck==192 | df$dck==215) & !is.na(df$newid),df$newid,df$qcid)
  df$newid <- NULL
}

# dck 874, 1 id to correct
dck_start <- 1995
dck_end <- 2014
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  df$qcid <- ifelse ( df$dck == 874, ifelse( df$qcid == "CG 2960" , "CG2960", df$qcid ), df$qcid )
}

# dck 197, Danish & polar
# need to check I haven't mucked up ids with characters in them
#dck_start <- 1871
#dck_end <- 1956
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
#  fname <- paste0("/noc/mpoc/surface_data/TRACKING/FinalTrack/ANC_INFO/ids_to_join_197.txt")
#  tosub <- read.table(fname,sep=",")
#  names(tosub)<-c("id","newid")
#  df<-merge(df,tosub,by="id",all.x=TRUE)
#  df$qcid<-ifelse(df$dck==197 & !is.na(df$newid) & nchar(df$newid) > 3,df$newid,df$qcid)
#}

# dck 197, Danish Polar, variety of ids
dck_start <- 1871
dck_end <- 1956
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
if ( max_yr >= dck_start & min_yr <= dck_end ) {
  totest <- gsub('[A-Z]','99',df$qcid)
  totest[which(is.na(totest))] <- 99
  totest <- gsub("[[:punct:]]",'99',totest)
  totest <- gsub("[a-z]",'99',totest)
  totest <- gsub(" ",'99',totest)
  df$qcid <- ifelse ( df$dck == 197, ifelse( df$qcid == "85" , "854", df$qcid ), df$qcid )
# info on ships from TDF-11 manual, UK info not clear
#  df$qcid <- ifelse ( df$dck == 197, ifelse( nchar(df$qcid) == 3 & as.numeric(totest) >= 500 & as.numeric(totest) <= 585 , "SCORESBY_d197", df$qcid ), df$qcid )
#  df$qcid <- ifelse ( df$dck == 197, ifelse( nchar(df$qcid) == 3 & as.numeric(totest) >= 586 & as.numeric(totest) <= 797 , "DISCOVERY_d197", df$qcid ), df$qcid )
  df$qcid[which(df$qcid %in% seq(500,585) & df$dck == 197)] <- "UK01-d197"
  df$qcid[which(df$qcid %in% seq(586,797) & df$dck == 197)] <- "UK02-d197"
  df$qcid[which(df$qcid %in% seq(800,999) & df$dck == 197)] <- "SEDOV-d197"
  #df$qcid <- ifelse ( df$dck == 197, ifelse( nchar(df$qcid) == 3 & as.numeric(totest) >= 500 & as.numeric(totest) <= 585 , "UK01_d197", df$qcid ), df$qcid )
  #df$qcid <- ifelse ( df$dck == 197, ifelse( nchar(df$qcid) == 3 & as.numeric(totest) >= 586 & as.numeric(totest) <= 797 , "UK02_d197", df$qcid ), df$qcid )
  #df$qcid <- ifelse ( df$dck == 197, ifelse( nchar(df$qcid) == 3 & as.numeric(totest) >= 800 & as.numeric(totest) <= 999 , "SEDOV_d197", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 197, ifelse( nchar(df$qcid) == 3 & df$id == "799" , "SCOTIA_d197", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 197, ifelse( nchar(df$qcid) == 3 & df$id == "798" , "POURQUOI_PAS_d197", df$qcid ), df$qcid )
}

 df$qcid <- ifelse (df$dck == 555 & substr(df$id,1,1) == "P-" & df$lat > 40, paste0("N",df$id),df$qcid)
 df$qcid <- ifelse (df$dck == 555 & substr(df$id,1,1) == "P-" & df$lat < 40, paste0("S",df$id),df$qcid)

# output of gap filling
if ( FALSE) {
  gapdata.tmp <- subset(gapdata,yr %in% names(table(df$yr)))
  gapdata.tmp <- subset(gapdata.tmp,mo %in% names(table(df$mo)))  # this to avoid warning for no data
  if ( dim(gapdata.tmp)[1] > 0 )  {
    #df.gaps <- df
    #print('merging gap data')
    df.gaps<-merge(df,gapdata.tmp[,c("uid","oldid","gapid","dist")],by="uid",all.x=T)
    df.gaps$qcid <- ifelse(!is.na(df.gaps$gapid),df.gaps$gapid,df.gaps$qcid)
    df<-df.gaps
    df.gaps$oldid<-NULL
    df.gaps$gapid<-NULL
    df.gaps$dist<-NULL
    #df$qcid <- df.gaps$qcid
    #rm(df2)
  } else {
    print('no gap data this month')
  }
}

if ( FALSE) {
  call.dcks <-c(128,233,254,255,555,700,708,709,735,749,781,792,849,874,875,888,889,892,926,927,992)
  call.data<-read_txt_comma(".","call_rep")
  df<-read_trackmonth("R3MONTHLY/",syr=1992)
  df<-merge(df,call.data[,c("uid","newcall")],all.x=T)
  df$qcid <- ifelse(!is.na(df$newcall) & df$dck %in% call.dcks,df$newcall,df$qcid)
  sub<-subset(df,qcid %in% names(table(df$newcall)))
  df$newcall<-NULL
}

df$qcid <- ifelse ( df$dck == 926 & grepl("^[0-9] ",df$id),trimws(substr(df$id,3,9)),df$qcid)

if (FALSE ) {
# some ad hoc changes
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "4XFEE", "4XFE", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "4XF0", "4XFO", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "3ESU", "3ESU8", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "3FDL", "3FDL4", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9MBQ", "9MBQ6", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9MBR", "9MBR8", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9MBW", "9MBW7", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9MCD", "9MCD3", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9MCM", "9MCM4", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9MCN", "9MCN8", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9MCY", "9MCY3", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9MET", "9MET6", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9VHZ", "9VHZ4", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "9VYO", "9VYO2", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "A8AA", "A8AA6", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "A8AC", "A8AC5", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "A8AF", "A8AF6", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "A8AI", "A8AI3", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "C6FE", "C6FE6", df$qcid)
df$qcid <- ifelse ( df$dck == 992 & df$yr == 2002 & df$id == "C6I0", "C6I09", df$qcid)
}

df$qcid <- ifelse ( df$dck == 116 & df$yr == 1953 & df$id == "404", "4045", df$qcid)
df$qcid <- ifelse ( df$yr == 2000 & (df$dck == 792 | df$dck == 700 ) & substr(df$id,4,6) == "JAN", paste0("XX_",substr(df$id,4,6)), df$qcid)

df$qcid <- gsub("[[:punct:]]","-",df$qcid)
df$qcid <- gsub(" ","_",df$qcid)
#df$qcid <- gsub("_-","-",df$qcid)
#df$qcid <- gsub("-_","-",df$qcid)
#df$qcid <- gsub("_-","-",df$qcid)
#df$qcid <- gsub("-_","-",df$qcid)

#df$qcid <- gsub("__","_",df$qcid)
#df$qcid <- gsub("__","_",df$qcid)
#df$qcid <- gsub("__","_",df$qcid)

#df$qcid <- gsub("--","-",df$qcid)
#df$qcid <- gsub("--","-",df$qcid)
#df$qcid <- gsub("--","-",df$qcid)

df$qcid[!grepl("[A-Z,a-z,0-9]",df$qcid)]<-NA

#df$qcid[which(df$qcid=="_")] <- NA
#df$qcid[which(df$qcid=="-")] <- NA
#df$qcid[which(df$qcid=="__")] <- NA
#df$qcid[which(df$qcid=="--")] <- NA
#df$qcid[which(df$qcid=="___")] <- NA
#df$qcid[which(df$qcid=="---")] <- NA

  #df$qcid <- ifelse ( df$dck == 762 & idt == "NNNNN", ifelse( paste0(df$qcid,"_KOBE"), df$qcid ), df$qcid )
  #df$qcid <- ifelse ( df$dck == 762 & idt == "NNNNC", ifelse( paste0(df$qcid,"_KOBE"), df$qcid ), df$qcid )
  #df$qcid <- ifelse ( df$dck == 116, ifelse( paste0(df$qcid,"_USNAV"), df$qcid ), df$qcid )
  #df$qcid <- ifelse ( df$dck == 195, ifelse( paste0(df$qcid,"_USNAV"), df$qcid ), df$qcid )
  #df$qcid <- ifelse ( df$dck == 197, ifelse( paste0(df$qcid,"_d197"), df$qcid ), df$qcid )
  #df$qcid <- ifelse ( df$dck == 740, ifelse( paste0(df$id,"_SAMOS"), df$qcid ), df$qcid )

return(df)

}
