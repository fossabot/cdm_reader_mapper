
#read_rdsfiles <- function (listf ) {
read_rdsfiles <- function (fdir = ".", pattern="" ) {
# df is the data frame to return
# listf is the list of .Rda files to read

listf <- list.files(path=fdir,pattern=pattern,full.names=TRUE)

df <- readRDS(listf[1])

	if ( length(listf) > 1 ) {
       	  for ( file in listf[2:length(listf)]) {
       	  tmp <- readRDS(file)
       	  df<-rbind(df,tmp)
	}
}

return(df)
}

read_txt_comma <- function (fdir = ".", pattern="" ) {
# df is the data frame to return
# listf is the list of .Rda files to read

listf <- list.files(path=fdir,pattern=pattern,full.names=TRUE)

df <- read.table(listf[1],sep=',',header=T)

        if ( length(listf) > 1 ) {
          for ( file in listf[2:length(listf)]) {
          tmp <- read.table(file,sep=',',header=T,fill=T)
          df<-rbind(df,tmp)
        }
}

return(df)
}


read_trackmonth <- function (fdir = "TRACK_MONTH", syr, eyr=syr, smo = 1, emo = 12 ) {
# df is the data frame to return
# listf is the list of .Rda files to read

listf <- list.files(path=fdir,pattern=as.character(syr),full.names=TRUE)

if ( syr != eyr ) {
	for ( year in seq(syr+1,eyr) ) {
		cyear <- as.character(year)
		listf <- c(listf,list.files(path=fdir,pattern=cyear,full.names=TRUE))
	}
}

#print(listf)
# this bit allows data with different columns to be appended
df.lst <- lapply(listf, readRDS)             # read all dataframes into a list
col <- unique(unlist(sapply(df.lst, names))) # get all column names from list
df.lst <- lapply(df.lst, function(df) {      # append columns of NA if missing
  df[, setdiff(col, names(df))] <- NA
  df
})

df<-do.call(rbind, df.lst)                   # and append all the files in the list

#df <- do.call( "rbind",lapply(listf, FUN=function(files){readRDS(files)}))

if ( !is.null(df) ) {
if ( smo != 1 ) { df <- subset(df,!(mo<smo & yr == syr)) }
if ( emo != 12 ) { df <- subset(df,!(mo>emo & yr == eyr)) }
test<-df$date[1]
if ( !is.null(test) ) {
df<-df[order(df$date),]
}
}

return(df)
}

read_datmonth <- function (fdir = "TRACK_MONTH", syr, eyr=syr, smo = 1, emo = 12 ) {
# df is the data frame to return
# listf is the list of .dat files to read

listf <- list.files(path=fdir,pattern=as.character(syr),full.names=TRUE)
listf<-listf[grep("Rda",listf,invert=TRUE)]

if ( syr != eyr ) {
        for ( year in seq(syr+1,eyr) ) {
                cyear <- as.character(year)
                listf <- c(listf,list.files(path=fdir,pattern=cyear,full.names=TRUE))
                listf<-listf[grep("Rda",listf,invert=TRUE)]
        }
}

df <- do.call( "rbind",lapply(listf, FUN=function(files){read.table(files,header=TRUE,sep=";",comment.char="",quote="",fill=T)}))

if ( !is.null(df) ) {
if ( smo != 1 ) { df <- subset(df,!(mo<smo & yr == syr)) }
if ( emo != 12 ) { df <- subset(df,!(mo>emo & yr == eyr)) }
test<-df$date[1]
if ( !is.null(test) ) {
df<-df[order(df$date),]
}
}

return(df)
}

rbind.all.columns <- function(x, y) {

    x.diff <- setdiff(colnames(x), colnames(y))
    y.diff <- setdiff(colnames(y), colnames(x))

    x[, c(as.character(y.diff))] <- NA

    y[, c(as.character(x.diff))] <- NA

    return(rbind(x, y))
}
