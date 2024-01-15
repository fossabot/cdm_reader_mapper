
#f.tmp<-unique(cbind(df$yr,df$mo))

get_dup_uid <- function(df=df) {

  #yy <- names(table(df$yr))
  #mm <- names(table(df$mo))
  yy1<-range(df$yr)[1]
  yy2<-range(df$yr)[2]
  mm1<-range(df$mo)[1]
  mm2<-range(df$mo)[2]

  #yymm<-expand.grid(yy,mm,stringsAsFactors=FALSE)
  df$dup<-FALSE

  #files<-paste0("/noc/mpoc/surface_data/TRACKING/FinalTrack/DUPLICATE/dups_",yymm$Var1,"_",yymm$Var2,".txt")
  #files<-paste0("/pgdata/eck/R3MONTHLY/REMOVED_DUPS/dups_",yymm$Var1,"_",yymm$Var2,".txt")

  uid.dup<-read_trackmonth("/pgdata/eck/R3MONTHLY/REMOVED_DUPS/",syr=yy1,eyr=yy2)
  df$dup[which(df$uid %in% uid.dup$uid)] <- TRUE

  #for ( file in files ) {
  #  if ( file.exists(file) ) {
  #   uid.dup<-read.table(file,sep=",")
  #   uid.dup<-unique(uid.dup)
  #   df$dup[which(df$uid %in% uid.dup$V2)] <- TRUE
  #  }
  #}

  if ( yy1 >= 1961 & yy1 <= 1994 ) {
  uid.mdup<-read_trackmonth("/noc/mpoc/surface_data/TRACKING/FinalTrack/MONTH_MISMATCH/",syr=yy1,eyr=yy2)
  if ( !is.null(uid.mdup) ) {
   if ( nrow(uid.mdup) > 0 ) {
    # got multiple matches - pick one
    uid.mdup$want<-FALSE
    tt<-table(uid.mdup$uid)
    ttn<-names(tt[which(tt==1)])
    uid.mdup$want<-ifelse(uid.mdup$uid %in% ttn,TRUE,uid.mdup$want)
    worst<-subset(uid.mdup,dup.shift.month==1)
    for ( i in 1:nrow(worst) ) {
     ind<-which(worst$uid==worst$uid[i])
     if ( length(ind) == 1 ) {
      worst$want[ind]<-TRUE
     } else {
      sub<-worst[ind,]
      idtest<-sub$newid
      #cat(idtest,'\n')
      if ( length(idtest) == 2 ) {
       if ( is.na(idtest[1]) & is.na(idtest[2])) {
         worst$want[ind[1]] <- TRUE
       } else if ( is.na(idtest[1]) & !is.na(idtest[2])) {
         worst$want[ind[2]] <- TRUE
       } else if ( idtest[1]==idtest[2]) {
         worst$want[ind[1]] <- TRUE
       } else {
         cat(idtest,'\n')
       }
      } else {
       cat(idtest,'\n')
      }
     }
    } # end loop over rows of worst
    #best<-subset(uid.mdup,dup.shift.month==0)
    worst<-worst[worst$want,]
    worst$want<-NULL
    df$dup[which(df$uid %in% worst$uid)] <- TRUE
    len.df<-nrow(df)
    df<-merge(df,worst[,c("uid","newid")],all.x=T)
    #df$qcid<-ifelse(!is.na(df$newid),df$newid,df$qcid)
    #df$newid<-NULL
    len.df2<-nrow(df)
    if ( len.df2 != len.df ) {cat("HELP",'\n')}
   }
  }
  } # end select for pre-1995

  return(df)
}
