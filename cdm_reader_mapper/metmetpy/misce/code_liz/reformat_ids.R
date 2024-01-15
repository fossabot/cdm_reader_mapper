
reformat_ids <- function(df) {

df$qcid <- df$id

if ( !("c1" %in% names(df) ) ) df$c1 <- NA

idt<-df$id
idt<-gsub("[A-Z]","C",idt)
idt<-gsub("[a-z]","c",idt)
idt<-gsub("[0-9]","N",idt)
name_dcks <- c(702,704,246,730,701,731,721,710,247,711,734,249,248,736,245,249,761,750,146,897,705,706,707)
#dck.mdb5 <- c(201,202,203,204,206,207,209,221,213,214,218,221,223,224,226,227,229,230,233,234,239,254,255)
# dck 218 -> US
# dck 254 -> general?
dck.mdb5 <- c(201,202,203,204,206,207,209,211,221,213,214,221,223,224,226,227,229,230,234,239,255)

idt <- ifelse ( df$dck %in% name_dcks, "name", idt )

min_yr <- min(df$yr)
max_yr <- max(df$yr)

# dck 702, Norwegian log book, ship names, some need correcting
dck_start <- 1867
dck_end <- 1889
if ( min_yr >= dck_start & max_yr <= dck_end ) {
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "ALLADIN" , "ALADDIN", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "ELLID" , "ELLIDA", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "N-C-_KIE" , "N-C-KIRK", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "N-C-KIE" , "N-C-KIRK", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "PH_ENIX" , "PHOENIX", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "PH ENIX" , "PHOENIX", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "PH_NIX" , "PHOENIX", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "PH NIX" , "PHOENIX", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "HANSTEN" , "HANSTEEN", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "TENAX_PR" , "TENAXPRO", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 702, ifelse( df$qcid == "TENAX PR" , "TENAXPRO", df$qcid ), df$qcid )
}

# dck 187, Japanese Whaling Fleet, 4 digit, by ship
dck_start <- 1946
dck_end <- 1956
if ( min_yr >= dck_start & max_yr <= dck_end ) {
  df$qcid <- ifelse ( df$dck == 187, ifelse( df$qcid == "2" , "0202", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 187, ifelse( df$qcid == "8" , "0708", df$qcid ), df$qcid )
}

# dck 184, GB Marine, 194 extension
dck_start <- 1953
dck_end <- 1961
if ( min_yr >= dck_start & max_yr <= dck_end ) {
# 184 IDs should be xNN 00000, where NN is 09,10 or 14, x is region so needs to be dropped
# 09 are ships, 10 & 14 are OWS, 10 from 1953-1956, 14 from 1956-1961
 ss1 <- trimws(substr(df$id,1,3))
 ss2 <- trimws(substr(df$id,nchar(ss1)+1,9))
 ss2 <- paste0("000000",ss2)
 ss2 <- substr(ss2,nchar(ss2)-4,nchar(ss2))
 ss2 <- ifelse ( ss2 == "00000", "0", ss2)
 ss2 <- ifelse ( ss2 == "000NA", "0", ss2)
 l1 <- nchar(ss1)
 # pt 0, should start with 09
 ss1 <- ifelse(df$pt==0,"09 ",ss1)
 ss1 <- ifelse(substr(ss1,l1,l1) == "4", "14 ",ss1)
 ss1 <- ifelse(substr(ss1,l1-1,l1) == "41", "14 ",ss1)
 ss1 <- ifelse(substr(ss1,l1-1,l1) == "01", "14 ",ss1)
 ss1 <- ifelse(substr(ss1,l1-1,l1) == "31" & df$yr < 1956, "10 ",ss1)
 ss1 <- ifelse(substr(ss1,l1-1,l1) == "31" & df$yr >= 1956, "14 ",ss1)
 ss1 <- ifelse(substr(ss1,l1,l1) == "0", "10 ",ss1)
 newid <- paste0(ss1,ss2)
 df$qcid <- ifelse ( df$dck == 184, newid, df$qcid )
}

# dck 194, GB marine
#dck_start <- 1856
#dck_end <- 1955
#if ( min_yr >= dck_start & max_yr <= dck_end ) {
## IDs are 1,2,3,4,6,7 followed by 5 digit ID, replace blanks with 0
# tmpid<-ifelse(!is.na(df$id),df$id,"")
# substr(tmpid,2,2)<-ifelse(nchar(tmpid) == 6 & substr(tmpid,2,2) == " ","0",substr(tmpid,2,2))
# substr(tmpid,3,3)<-ifelse(nchar(tmpid) == 6 & substr(tmpid,3,3) == " ","0",substr(tmpid,3,3))
# df$qcid <- ifelse ( df$dck == 194, tmpid, df$qcid )
#}

# dck 897, ship Eltanin
dck_start <- 1962
dck_end <- 1963
if ( min_yr >= dck_start & max_yr <= dck_end ) {
  df$qcid <- ifelse ( df$dck == 897, ifelse( is.na(df$qcid) , "Eltanin", df$qcid ), df$qcid )
}

# dck 711, Weather Detective, correct minor typos
dck_start <- 1889
dck_end <- 1899
if ( min_yr >= dck_start & max_yr <= dck_end ) {
  df$qcid <- ifelse ( df$dck == 711, ifelse( df$qcid == "Gulf_of_l" , "Gulf_of_L", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 711, ifelse( df$qcid == "Gulf of l" , "Gulf_of_L", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 711, ifelse( df$qcid == "Rotokino" , "Rotohino", df$qcid ), df$qcid )
  df$qcid <- ifelse ( df$dck == 711, ifelse( df$qcid == "Unknown_711_1" , " ", df$qcid ), df$qcid )
  #df<-subset(df,qcid!="Ringaroon")
}

# dck 780 and 782, WOD and GOSUD, make ids consistent and distinctive
# NNNNNNN-CC-WOD
# NNNNNNN-CC-GOSUD
dck_start <- 1663
dck_end <- 2020
if ( min_yr >= dck_start & max_yr <= dck_end ) {
  tmp.wod<-paste0("00000000",trimws(df$qcid))
  lwod <- nchar(tmp.wod)
  tmp.wod[which(substr(tmp.wod,lwod-1,lwod) == "NA")] <- "00000000"
  tmp.wod<-substr(tmp.wod,nchar(tmp.wod)-6,nchar(tmp.wod))
  ctmp <- ifelse(!is.na(df$c1),df$c1,"99")
  df$qcid <- ifelse ( df$dck == 780, tmp.wod, df$qcid )
  #df$qcid <- ifelse ( df$dck == 780, paste0(df$qcid,"_",df$c1), df$qcid )
  df$qcid <- ifelse ( df$dck == 780, paste0(df$qcid,"_",ctmp), df$qcid )
  df$qcid <- ifelse ( df$dck == 780, paste0(df$qcid,"_WOD"), df$qcid )
  df$qcid <- ifelse ( df$dck == 782, tmp.wod, df$qcid )
  #df$qcid <- ifelse ( df$dck == 782, paste0(df$qcid,"_",df$c1), df$qcid )
  df$qcid <- ifelse ( df$dck == 782, paste0(df$qcid,"_",ctmp), df$qcid )
  df$qcid <- ifelse ( df$dck == 782, paste0(df$qcid,"_GOSUD"), df$qcid )
}

df$qcid <- ifelse ( df$dck == 740, paste0(df$id,"_SAMOS"), df$qcid )

# dck 902, GB marine, 184 extension, shoud be 8 digit, add missing "3" from start for some
dck_start <- 1957
dck_end <- 1961
if ( min_yr >= dck_start & max_yr <= dck_end ) {
  df$qcid <- ifelse ( df$dck == 902, ifelse( nchar(df$qcid==7) & substr(df$qcid, 1, 3) == "131" , paste0("3",df$qcid), df$qcid ), df$qcid )
}

# Kobe decks 118 & 119 ids should be 0-5, yy, nnn
# correct 3 digit ids by inserting year and _ for leading digit
dck_start <- 1930
dck_end <- 1961
if ( min_yr >= dck_start & max_yr <= dck_end ) {
#print("dcks 118 and 119")
  yy <- substr(df$yr,3,4)
  tmpid <- paste0("_",yy,df$qcid)
  df$qcid <- ifelse ( (df$dck == 118 | df$dck == 119) & nchar(df$qcid) == 3 & substr(df$qcid,2,3) == yy, tmpid, df$qcid )
  df$qcid<- ifelse ( (df$dck == 118 | df$dck == 119) & nchar(df$qcid) == 5, paste0(df$qcid,"-d",df$dck),df$qcid )
}

# 116, 5 digit ID, add -d116
# common id fragments between 116, 117, 218, allow to match
  tmpid <- ifelse(!is.na(df$qcid),df$qcid,"")
  df$qcid<- ifelse ( df$dck %in% c(116,117,218) & idt == "NNNNN" , paste0(df$id,"-US"),df$qcid )
  df$qcid<- ifelse ( df$dck %in% c(116,117,218) & idt == "NNNN" , paste0(df$id,"-US"),df$qcid )
  df$qcid<- ifelse ( df$dck %in% c(116,117,218) & idt == "-NNNN" , paste0(df$id,"-US"),df$qcid )
  df$qcid<- ifelse ( df$dck %in% c(116,117,218) & idt == "-NNN" , paste0(df$id,"-US"),df$qcid )
  df$qcid<- ifelse ( df$dck %in% c(128) & idt == "NNNNN" & df$yr <= 1965 , paste0(df$id,"-US"),df$qcid )
  df$qcid<- ifelse ( df$dck %in% c(128) & idt == "NNNN" & df$yr <= 1965 , paste0(df$id,"-US"),df$qcid )
  df$qcid<- ifelse ( df$dck %in% c(128) & idt == "-NNNN" & df$yr <= 1965 , paste0(df$id,"-US"),df$qcid )
  df$qcid<- ifelse ( df$dck %in% c(128) & idt == "-NNN" & df$yr <= 1965 , paste0(df$id,"-US"),df$qcid )
# 116, 3 digit ID & pt == 3, add -d116 - -US
  tmpid <- ifelse(!is.na(df$qcid),df$qcid,"")
  df$qcid<- ifelse ( df$dck == 116 & idt == "NNN" & df$pt == 3 , paste0(df$qcid,"-US"),df$qcid )
# 117 2 digit IDs seem OK
  tmpid <- ifelse(!is.na(df$qcid),df$qcid,"")
  df$qcid<- ifelse ( df$dck == 117 & idt == "NN", paste0(df$qcid,"-US"),df$qcid )
# 735, all IDs, add -d735
  tmpid <- ifelse(!is.na(df$qcid),df$qcid,"")
  df$qcid<- ifelse ( df$dck == 735, paste0(df$id,"-d",df$dck),df$qcid )
  #df$qcid<- ifelse ( df$dck == 735 & idt == "NNNNN" , paste0(df$qcid,"-d",df$dck),df$qcid )
  #df$qcid<- ifelse ( df$dck == 735 & idt == "NNNN" , paste0(df$qcid,"-d",df$dck),df$qcid )
  #df$qcid<- ifelse ( df$dck == 735 & df$id == "8082A" , paste0(df$qcid,"-d",df$dck),df$qcid )
# 900, 3 digit ID, add -d900
  tmpid <- ifelse(!is.na(df$qcid),df$qcid,"")
  df$qcid<- ifelse ( df$dck == 900 & idt == "NNN" , paste0(df$qcid,"-d",df$dck),df$qcid )
# 118 & 119 6 digit, add -d119
  tmpid <- ifelse(!is.na(df$qcid),df$qcid,"")
  df$qcid<- ifelse ( (df$dck == 119 | df$dck == 118) & idt == "NNNNNN" , paste0(df$qcid,"-d",df$dck),df$qcid )
# MDB dcks, 5 digit ID, add -mdb5
  #df$qcid<- ifelse ( df$dck %in% dck.mdb5 & idt == "NNNNN" , paste0(tmpid,"-mdb5"),df$qcid )
  df$qcid<- ifelse ( df$dck %in% dck.mdb5 & idt == "NNNNN" , paste0(tmpid,"-d",df$dck),df$qcid )

# sort out sequential IDs, unique ID per ob
# dck 720 for sid 135 has unique ids for every ob, first 4 digits define ship

df$qcid <- ifelse ( df$dck == 926 & grepl("^[0-9] ",df$id),trimws(substr(df$id,3,9)),df$qcid)
df$qcid <- ifelse ( df$dck == 233, substr(df$qcid,2,5), df$qcid )

df$qcid <- ifelse ( df$dck == 720 & df$sid == 135 & nchar(df$id) == 8, paste0(substr(df$id,1,4),"-SEQ") , df$qcid )

return(df)

}
