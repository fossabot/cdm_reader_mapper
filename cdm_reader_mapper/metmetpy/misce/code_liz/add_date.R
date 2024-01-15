
is.leapyear=function(year){
  #http://en.wikipedia.org/wiki/Leap_year
  return(((year %% 4 == 0) & (year %% 100 != 0)) | (year %% 400 == 0))
}

add_date <- function(df2){

#------------------------------------------------------------------------------------------------------
# add date variable
#------------------------------------------------------------------------------------------------------
#print('about to add date')
                df2$hr2<-df2$hr
                df2$hr2[which(is.na(df2$hr))]<-0
                df2$tmp<-strftime(as.POSIXct(df2$hr2 * 60 * 60,
                        origin = "0001-01-01", tz = "GMT"), format = "%H:%M:%S")
                # need to catch and remove any data with invalid dates (e.g. 31 June)
                df2$dy[which(df2$mo==6 & df2$dy==31)] <- NA
                df2$dy[which(df2$mo==9 & df2$dy==31)] <- NA
                df2$dy[which(df2$mo==4 & df2$dy==31)] <- NA
                df2$dy[which(df2$mo==11 & df2$dy==31)] <- NA
                df2$dy[which(df2$mo==2 & df2$dy>29)] <- NA
                df2$dy[!is.leapyear(df2$yr) & df2$mo==2 & df2$dy==29] <- NA

#------------------------------------------------------------------------------------------------------
# convert date format
#------------------------------------------------------------------------------------------------------
        # put in valid day so date calc doesn't fall over, put NA in statement
        df2$dy<-ifelse(is.na(df2$dy),1,df2$dy)
        df2$hr<-ifelse(is.na(df2$hr),0,df2$hr)
        d.date<-as.POSIXlt(paste0(df2$yr,"-",df2$mo,"-",df2$dy," ",df2$tmp))
        valid.date <- !is.na(df2$dy) & !is.na(df2$hr)
        df2$date <- d.date
        df2$date[!valid.date] <- NA
        df2$hr2<-NULL
        df2$tmp<-NULL
return(df2)
}
