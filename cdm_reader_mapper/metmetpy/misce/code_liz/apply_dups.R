
apply_dups <- function(df)  {

  source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/get_mismatch.R")
  source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/read_rdsfiles.R")
  suppressMessages(require(stringdist))

  options(warn=1)
  options(width=100)

  #data<-readRDS("1880.1.Rda")
  #data<-read_trackmonth(fdir="TRIAL_RUN/HOOVER/",syr=1850)

  dup.data <- NULL
  for ( year in names(table(df$yr))) {
   for ( month in names(table(df$mo))) {
    dup.file <- paste0("/noc/mpoc/surface_data/TRACKING/FinalTrack/DUPLICATE/dups_",year,"_",month,".txt")
    if ( file.exists(dup.file)) {
      tmp<-read.table(dup.file,sep=",")
      if ( is.null(dup.data) ) {
        dup.data <- tmp
      } else {
        dup.data <- rbind(dup.data,tmp)
        dup.data<-unique(dup.data)
      }
    }
   }
  }

  uids<-c()
  if (!is.null(dup.data) ) {

    tol <- 0.1
    tol.1 <- 1
    mid.dcks <-c(110,117,189,192,193,194,196,201,202,203,204,205,207,209,211,213,214,215,216,221,223,227,229,230,233,239,254,255,281,666,667,700,704,705,706,707,708,709,720,735,792,875,892,898,900,902,926,927,928,992)
    hsst.dcks <- c(150,151,152,155,156)
    station.dcks <- c(186,206,210,214,218,224,226,234,733,734,896)   # OWS, ice stations etc.
    good.dcks <- c(118,119,184,186,187,188,195,197,245,246,247,249,701,702,703,710,711,721,730,731,736,750,762)
    bad.dcks <-c(128,555,732,749,781,849,850,874,888,889,901,999)
    whale.dcks <- c(187,188,761,899)
    no.dup <- c(701,730,721,730,740,780,782,897)

    if ( dim(dup.data)[1] > 0 & dim(df)[1] > 0 ) {
      names(dup.data) <- c("uid1","uid2")

     for ( irec in 1:length(dup.data$uid1) ) {

      # subset data to get only possible duplicates

      test <- subset(df,uid == dup.data$uid1[irec] | uid == dup.data$uid2[irec])
      if ( dim(test)[1] != 2 ) {next}

      if ( test$dck[1] %in% no.dup | test$dck[2] %in% no.dup ) {next}

        comp.list.full=c("lon","lat","date","sst","slp","at","w","d","vv","ww","dpt","n","ww","id","dck")
        comp.list=c("sst","slp","at","w","d","vv","ww","dpt","n","ww")
        lat.diff <- round(abs(test$lat[1]-test$lat[2]),2)
        lon.diff <- round(abs(test$lon[1]-test$lon[2]),2)
        time.diff <- abs(as.numeric(test$date[1])-as.numeric(test$date[2]))/60/60 # in hours
        sst.diff <- round(abs(test$sst[1]-test$sst[2]),2)
        slp.diff <- round(abs(test$slp[1]-test$slp[2]),2)
        at.diff <- round(abs(test$at[1]-test$at[2]),2)
        w.diff <- round(abs(test$w[1]-test$w[2]),2)
        d.diff <- round(abs(test$d[1]-test$d[2]),0)
        d.diff <- round(ifelse(d.diff > 300, abs(d.diff-360),d.diff),0)
        vv.diff <- round(abs(test$vv[1]-test$vv[2]),0)
        ww.diff <- round(abs(test$ww[1]-test$ww[2]),0)
        dpt.diff <- round(abs(test$dpt[1]-test$dpt[2]),2)
        n.diff <- round(abs(test$n[1]-test$n[2]),0)
        ww.diff <- round(abs(test$ww[1]-test$ww[2]),0)
        id.diff <- stringdist(test$id[1],test$id[2])
        numel1 <- sum(!is.na(test[1,comp.list]))
        numel2 <- sum(!is.na(test[2,comp.list]))
        same <- 0
        similar <- 0
        diss <- 0
        for ( i in comp.list ) {
        if ( !is.na(test[1,i]) & !is.na(test[2,i])) {
            #print(paste(i,test[1,i],test[2,i]))
            if ( abs(test[1,i]-test[2,i]) < tol ) {same <- same + 1}
            if ( abs(test[1,i]-test[2,i]) <= 1 ) {similar <- similar + 1}
            if ( abs(test[1,i]-test[2,i]) > 1 ) {diss <- diss + 1}
            #print(paste(i,same,similar))
          }
        }
        pos.diff <- lat.diff + lon.diff
        id1 <- ifelse(!is.na(test$id[1]),TRUE,FALSE)
        id2 <- ifelse(!is.na(test$id[2]),TRUE,FALSE)
        dck1 <- test$dck[1]
        dck2 <- test$dck[2]

      # now got info to consider duplicates

      if ( is.na(pos.diff) | is.na(lat.diff) | is.na(lon.diff) | is.na(time.diff) | is.na(numel1) | is.na(numel1) | is.na(same) | is.na(similar) | is.na(diss) ) {
         print(test[,c(comp.list.full)])
         print(paste(lat.diff,lon.diff,time.diff,numel1,numel2,id1,id2,same,similar,diss))
         {next}
      }

      if ( pos.diff < tol & time.diff == 0 & numel1 == numel2 & same == numel1 & id1 ) {
       # almost identical match, 1st report has ID, pick 2nd as duplicate
         #print("match 1")
         uids<-c(uids,test$uid[2])
      } else if ( pos.diff < tol & time.diff == 0 & numel1 == numel2 & same == numel1 & id2 ) {
         # almost identical match, 2nd report has ID, pick 1st as duplicate
         #print("match 2")
         uids<-c(uids,test$uid[1])
      } else if ( pos.diff < tol & time.diff == 0 & numel1 == numel2 & same == numel1) {
         # almost identical match, neither with ID
         #print("match 3")
         uid.add <- ifelse ( dck1 %in% hsst.dcks | dck1 %in% bad.dcks, test$uid[1], test$uid[2])
         uids<-c(uids,uid.add)
      } else if (pos.diff < tol & time.diff == 0 & numel1 > numel2 & same == numel2 & id1 ) {
         #print("match 4")
         # almost identical match, 2nd report has fewer elements and 1st report has ID
         uids<-c(uids,test$uid[2])
         #print("match 5")
      } else if (pos.diff < tol & time.diff == 0 & numel1 < numel2 & same == numel1 & id2 ) {
       # almost identical match, 1st report has fewer elements and 2nd report has ID
         #print("match 6")
         uids<-c(uids,test$uid[2])
      } else if ( lat.diff < tol.1 & lon.diff < tol.1 & time.diff == 0 & numel1 == numel2 & same >= numel1-1 & similar == numel1 & id1 ) {
         # almost identical match, 1st report has ID, pick 2nd as duplicate
         #print("match 1 with pos diff")
         uids<-c(uids,test$uid[2])
      } else if ( lat.diff < tol.1 & lon.diff < tol.1 & time.diff == 0 & numel1 == numel2 & same >= numel1-1 & similar == numel1 & id2 ) {
         # almost identical match, 2nd report has ID, pick 1st as duplicate
         #print("match 2 with pos diff")
         uids<-c(uids,test$uid[1])
      } else if ( lat.diff < tol.1 & lon.diff < tol.1 & time.diff == 0 & numel1 == numel2 & same >= numel1-1 & similar == numel1) {
         # almost identical match, neither with ID, pick 1st as duplicate
         #print("match 3 with pos diff")
         uid.add <- ifelse ( dck1 %in% hsst.dcks | dck1 %in% bad.dcks, test$uid[1], test$uid[2])
         uids<-c(uids,uid.add)
      } else if (lat.diff < tol.1 & lon.diff < tol.1 & time.diff == 0 & numel1 > numel2 & same >= numel2-1 & similar == numel2 & id1 ) {
         #print("match 4 with pos diff")
         # almost identical match, 2nd report has fewer elements and 1st report has ID
         uids<-c(uids,test$uid[2])
         #print("match 5 with pos diff")
      } else if (lat.diff < tol.1 & lon.diff < tol.1 & time.diff == 0 & numel1 < numel2 & same >= numel1-1 & similar == numel1 & id2 ) {
         # almost identical match, 1st report has fewer elements and 2nd report has ID
         #print("match 6 with pos diff")
         uids<-c(uids,test$uid[2])
      } else if (lat.diff < tol.1 & lon.diff < tol.1 & time.diff == 0 & similar == min(numel1,numel2) & !id1 & !id2 ) {
       # neither has ID and all matches are close
       #print("match 7 with pos diff")
         uid.add <- ifelse ( dck1 %in% hsst.dcks | dck1 %in% bad.dcks, test$uid[1], test$uid[2])
         uids<-c(uids,uid.add)
      } else if (lat.diff < tol.1 & lon.diff < tol.1 & time.diff == 0 & min(numel1,numel2) - similar > diss ) {
       # different elements present in the reports, consider for consolidation
         #print("different elements in 2 reports")
      } else if (lat.diff < tol.1 & lon.diff < tol.1 & time.diff == 0 & id1 & id2 & id.diff <= 1 & same == min(numel1,numel2) ) {
         uid.add <- ifelse ( numel1 > numel2, test$uid[2], test$uid[1])
         uids<-c(uids,uid.add)
      } else if ( id1 == id2 & time.diff == 0 & lat.diff < tol.1 & lon.diff < tol.1 & (dck1 == 892 | dck1 == 888) & dck2 == 926 ) {
         uids<-c(uids,test$uid[1])
      } else if ( id1 == id2 & time.diff == 0 & lat.diff < tol.1 & lon.diff < tol.1 & dck1 == 926 & (dck2 == 892 | dck2 == 888)) {
         uids<-c(uids,test$uid[2])
      } else {
         print(test[,c(comp.list.full)])
         print(paste(lat.diff,lon.diff,time.diff,numel1,numel2,id1,id2,same,similar,diss))
         #stop()
      }

      } # end loop over records

    } else {
    # no duplicates to check
    }
  }

  print(paste('no. candidate duplicates',dim(dup.data)[1],'no. accepted',length(uids)))
  return(uids)
}
