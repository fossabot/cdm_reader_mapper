
classify_ids <- function(df) {

source("/noc/mpoc/surface_data/TRACKING/FinalTrack/RSCRIPTS/reformat_ids.R")

df2 <- df
if ( is.null(df2$qcid) ) { df2<-reformat_ids(df2) }
#df2$qcid <- df2$id

min_year <- min(df2$yr)
max_year <- max(df2$yr)

idt<-df2$qcid
idt<-gsub("[A-Z]","C",idt)
idt<-gsub("[a-z]","c",idt)
idt<-gsub("[0-9]","N",idt)
upto4dig <- c("N","NN","NNN","NNNN")
upto5dig <- c("N","NN","NNN","NNNN","NNNNN")
upto6dig <- c("N","NN","NNN","NNNN","NNNNN","NNNNNN")
upto7dig <- c("N","NN","NNN","NNNN","NNNNN","NNNNNN","NNNNNNN")
form_name <- c("CCCC","CCCCC","CCCCCC","CCCCCCC","CCCCCCCC","CCCCCCCCC")
name_dcks <- c(702,704,246,730,701,731,721,710,247,711,734,249,248,736,245,249,761,750,146,897,705,706,707)
form_call <- c("CCCC","CNCC","NCCC","CCNC","CCCN","CNCN","CNNC","NCNC","NCC","CCCCN","CNCCN","NCCCN")
form_call_lc <- c("cccc","cNcc","Nccc","ccNc","cccN","cNcN","cNNc","NcNc","ccccN","cNccN","NcccN")
form_generic <- c("SHIP","BUOY","PLAT","RIGG","ship","MASKSTID","buoy","BBXX_SHIP","BBXX-SHIP","AAAA","XXXX","TEST")
form_cman <- c("CCCCN")
dck.mdb5 <- c(201,202,203,204,206,207,209,221,213,214,218,221,223,224,226,227,229,230,233,234,239,254,255)
 ship.names<-c("AVERY","ALEXAN","WILLIA","GULF G","SIR JA","AGAWAC","ARCTIC","GORDON","LOUISR","HILDA","R BRUC","STADAC","STANLE","BLACK","WHEATK","FRANK","ENGLIS","YANKCA","GRIFFO","ALGOCE","JEAN P","TADOUS","ALGORA","KENOKI","SPUME","REDWIN","JUDITH","VEREND","WOLVER","SILVER","SAGUEN","SPINDR","RICHEL","ALGOWA","TARANT","AGAWA","FRONTE","JAMES","QUEBEC","HOWARD","LOUIS","MONTRE","NORTHE","SPRAY","ALGOLA","ALGOSO","CAROL","MANITO","QUETIC","SIMCOE","LIMNOS","CANADI","BAYFIE","RAPID","NANTUC")

df2$idt <- ifelse ( df2$dck %in% name_dcks, "name", idt )
df2$idt <- ifelse ( is.na(df2$qcid), "miss",df2$idt)

df2$idtOK <- rep(FALSE,times=length(df2$id))
df2$idtype <- rep(NA,times=length(df2$id))

df2$idtOK <- ifelse(df2$dck %in% name_dcks, TRUE, df2$idtOK )

if ( max_year <= 1965 ) {
 df2$idtOK <- ifelse(df2$dck == 116, ifelse(df2$idt %in% c("NNNNN","NNNNN-cNNN","NNNN","NNNN-cNNN","-NNNN","-NNNN-cNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 116, ifelse(df2$idt %in% c("NNN","NNN-cNNN") & df2$pt==3, TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 117, ifelse(df2$idt %in% c("NNNN","-NNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 118, ifelse(df2$idt %in% c("NNNNNN","NNNNNN-cNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 119, ifelse(df2$idt %in% c("NNNNNN","NNNNNN-cNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 184, ifelse(df2$idt %in% c("NN_NNNNN","NN-NNNNN"),TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 187, ifelse(df2$idt %in% c("NNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 188, ifelse(df2$idt %in% c("N"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 189, ifelse(df2$idt %in% c("NNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 192, ifelse(df2$idt %in% c("NNNNNNNN","NNNNCNNN","NNNN---N","NNNN___N"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 194, ifelse(df2$idt %in% c("NNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 #df2$idtOK <- ifelse(df2$dck == 194 & df2$sid == 90, ifelse(df2$idt %in% c("NNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 194 & (df2$sid == 1 | df2$sid == 6), ifelse(df2$idt %in% c("N_NNNN","N-NNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 195, ifelse(df2$idt %in% c("NNNNN","CNNNN","-NNNN","NNNNN-cNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 196, ifelse(df2$idt %in% c("NNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 197, TRUE, df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 201, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 202, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 203, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 204, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 206, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 207, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 209, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 210, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 211, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 213, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 214, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 215, ifelse(df2$idt %in% c("NNNNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 216, ifelse(df2$idt %in% c("NNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 218, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 226, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 227, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 705, ifelse(df2$idt %in% c("CCNNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 706, ifelse(df2$idt %in% c("CCNNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 707, ifelse(df2$idt %in% c("CCNNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 902, ifelse(df2$idt %in% c("NNNNNNNN"), TRUE, df2$idtOK), df2$idtOK )
}

if ( max_year <= 1980 ) {
 df2$idtOK <- ifelse(df2$dck == 128, ifelse(df2$idt %in%
                  c("NNNN","-NNN","CNNN","NNCC","NCNN","NNCN",form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 128 & (df2$pt == 3 | df2$pt == 2), ifelse(df2$idt %in% c("NNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 186, ifelse(df2$idt %in% c("NNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 230, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 555, ifelse(df2$idt %in% c("C-NN","CC-N","CNNN","CC-NN",form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 703, ifelse(df2$idt %in% c("NNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 849, ifelse(df2$idt %in%
                  c("CCNNNN","CNN","CNC","CCNNN",form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 900, ifelse(df2$idt %in% c("NNN","NNN-cNNN"), TRUE, df2$idtOK), df2$idtOK )

}

if ( max_year <= 1990 ) {
 df2$idtOK <- ifelse(df2$dck == 221, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 223, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 224, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 229, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 720 & df2$sid == 135, ifelse(df2$idt %in% c("NNNN-CCC"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 720 & (df2$sid == 134 | df2$sid == 136), ifelse(df2$idt %in% c("NNNNNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 720 & (df2$sid == 160 | df2$sid == 161), ifelse(df2$idt %in% c("NNNNNNN","NNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 896, ifelse(df2$idt %in% c("CNC",form_call), TRUE, df2$idtOK), df2$idtOK )
}

if ( max_year <= 2000 ) {
 df2$idtOK <- ifelse(df2$dck == 233, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN",form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 234, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN",form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 239, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 254, ifelse(df2$idt %in%
                  c("NNNNN","NNNNN-cccN","NNNNNN","NNCCCC",form_call,paste0("N_",form_call),paste0("N",form_call)), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 255, ifelse(df2$idt %in% c("NNNNN","NNNNN-cccN",form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 667, ifelse(df2$idt %in% c("NNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 732, ifelse(df2$idt %in% c(form_call,"NNNNN"), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 781, ifelse(df2$idt %in% c(form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 888, ifelse(df2$idt %in%
                  c("CNC","NCC","CC-NN","CNNN","CCNN",form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 889, ifelse(df2$idt %in% c("CNNN",form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 892, ifelse(df2$idt %in%
                  c("CCNNN","CCNNNN","NNNN","NNNNN","CCCNNN","NNNNC","CNNN","CCC",form_call), TRUE, df2$idtOK), df2$idtOK )
}

df2$idtOK <- ifelse(df2$dck == 700, ifelse(df2$idt %in% c("NNNNN",form_call,form_name,"CCNNNN","CCCNNNN","CCCCCNN","CCNNN","CCCNN",paste0("CCCC_",form_call)), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 708, ifelse(df2$idt %in% c(form_call), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 709, ifelse(df2$idt %in% c(form_call), TRUE, df2$idtOK), df2$idtOK )
 df2$idtOK <- ifelse(df2$dck == 733, ifelse(df2$idt %in% c("CC-N","CC-NN"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 735, ifelse(df2$idt %in% c("NNNN","NNNNN","CCCC","CCCCC","NNNNC"), TRUE, df2$idtOK), df2$idtOK )
#df2$idtOK <- ifelse(df2$dck == 740, ifelse(df2$idt %in% c(form_call,"CCCNNNN"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 749, ifelse(df2$idt %in% c(form_call,"CCCCCC","CCCCC"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 762, ifelse(df2$idt %in% c("NNNNN","NNNNC","NNNN"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 780, ifelse(df2$idt %in% c("NNNNNNN_CC_CCC","NNNNNNN_NN_CCC","NNNNNNN-CC-CCC","NNNNNNN-NN-CCC"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 781, ifelse(df2$idt =="AAAA", FALSE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 782, ifelse(df2$idt %in% c("NNNNNNN_CC_CCCCC","NNNNNNN_NN_CCCCC","NNNNNNN-CC-CCCCC","NNNNNNN-NN-CCCCC"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 792, ifelse(df2$idt %in% c(form_call,form_call_lc,"CCNNN","CCCNNN","CNNCN","CCNNNN","CCCNNNN","NNNNNNN","CCCCCNN","NCNNNN","NCCNNNN","CNCCNN",form_name), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 795, ifelse(df2$idt %in% c(form_call), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 797, ifelse(df2$idt %in% c(form_call,"CCNNN"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 874, ifelse(df2$idt %in% c(form_call,"CCNNNN","CCCCC","CCCNNNN"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 875, ifelse(df2$idt %in% c(form_call), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 876, ifelse(df2$idt %in% c("NNNNN"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 926, ifelse(df2$idt %in%
                   c("NNN","NNNN","NNNNN","NNNNNN","NNNNNNN","NCN",form_name,"NNNCCCC",
                   "N_NNNN","CNC",
                   "CCNNN","CCCNNN","CCNNNN","CCCNNNN","NCCNNNN",form_call,form_call_lc,
                   paste0("NNN",form_call),"CNCNNN","CNCNNNN","CCCNN","NCNNNN","CCCCCNN",
                   paste0("NN",form_call),paste0("N_",form_call),paste0("N",form_call)),
                   TRUE, df2$idtOK), df2$idtOK )
#df2$idtOK <- ifelse(df2$dck == 927, ifelse(df2$idt %in% c("CCNNNN","CNC","-NNNN","-NNN","NNNN","NNNNN","CNNN","CCCNNN","CCCNNNN",form_call), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 927, ifelse(df2$idt %in% c("NNNNN","-NNN","CNNN","CNC","NNNN","CCNNNN","CCCNNNN",form_call), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 928, ifelse(df2$idt %in% c("NNNNNN"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 962, ifelse(df2$idt %in% c(form_call), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 992, ifelse(df2$idt %in% c(form_call,form_call_lc,"CNNCN","CCCNNN","CCCNNNN","CCNNNN","CCNNN","CCCCC","CNCNNNN","CCCCCNN","NCCNNNN","NCNNNN","CCCNN","NNNNNNN"), TRUE, df2$idtOK), df2$idtOK )
df2$idtOK <- ifelse(df2$dck == 995, ifelse(df2$idt %in% c(form_call,"NNNNN"), TRUE, df2$idtOK), df2$idtOK )
# 993 is supposed to be buoy data in ship code, but these have pt=5 and look like ships
df2$idtOK <- ifelse(df2$dck == 993, ifelse(df2$idt %in% c("NNNNN"), TRUE, df2$idtOK), df2$idtOK )

# specific IDs

df2$idtOK <- ifelse(df2$id == "ZSWAV1" | is.na(df2$id),  TRUE, df2$idtOK)
df2$idtOK <- ifelse(df2$id == "ERESP" | is.na(df2$id),  TRUE, df2$idtOK)
df2$idtOK <- ifelse(df2$id == "CG10" | is.na(df2$id),  TRUE, df2$idtOK)
df2$idtOK <- ifelse(df2$id == "EB01" | is.na(df2$id),  TRUE, df2$idtOK)
df2$idtOK <- ifelse(df2$id == "EB03" | is.na(df2$id),  TRUE, df2$idtOK)
df2$idtOK <- ifelse(df2$id == "EB10" | is.na(df2$id),  TRUE, df2$idtOK)
df2$idtOK <- ifelse(df2$id == "SAMARIA" | is.na(df2$id),  TRUE, df2$idtOK)

df2$idtOK <- ifelse(df2$qcid %in% form_generic, FALSE, df2$idtOK)

df2$idtOK <- ifelse(df2$dck == 740, TRUE, df2$idtOK )

#print(table(df2$idtOK))

# idtype - 1 = valid form, 2 = invalid form, 3 = generic, 4 = missing
df2$idtype <- ifelse(df2$idtOK,1,2)
df2$idtype <- ifelse(df2$qcid %in% form_generic,3,df2$idtype)
idtmp<-ifelse(!is.na(df2$qcid),df2$qcid,"")
df2$idtype <- ifelse((substr(idtmp,1,3) == "INT" & df2$idt == "CCCNNN"),  3, df2$idtype)
df2$idtype <- ifelse(substr(idtmp,1,14) == "0000000-99-WOD",  3, df2$idtype)
df2$idtype <- ifelse(substr(idtmp,1,16) == "0000000-99-GOSUD",  3, df2$idtype)
df2$idtype <- ifelse(idtmp == "AAAA" & df2$dck == 781, 3, df2$idtype)
d213.gen <- c("00013","00008","09999","00001","00009")
df2$idtype <- ifelse(idtmp %in% d213.gen & df2$dck == 213, 3, df2$idtype)
d215.gen <- c("00062","00002","99676","00061","00060","00004","00001","00041","00065","00006","00007")
df2$idtype <- ifelse(idtmp %in% d215.gen & df2$dck == 215, 3, df2$idtype)

#print(table(df2$idtype))
#df2$idtype <- ifelse(substr(idtmp,1,4) == "0000" & df2$dck == 213, 3, df2$idtype)
#df2$idtype <- ifelse(idtmp == "09999" & df2$dck == 213, 3, df2$idtype)
#df2$idtype <- ifelse(df2$qcid == "004" & df2$dck == 116, 3, df2$idtype)
df2$idtype <- ifelse(nchar(idtmp) == 1 & df2$dck == 194, 3, df2$idtype)
d.list <- c(192,215)
df2$idtype <- ifelse(df2$idt == "NNNN" & df2$dck %in% d.list, 3, df2$idtype)
yy <- substr(df2$yr,3,4)
df2$idtype <- ifelse ( (df2$dck == 118 | df2$dck == 119) & nchar(df2$qcid) == 3 & substr(df2$qcid,2,3) != yy, 3, df2$idtype )
df2$idtype[grep("BBXX",df2$qcid)] <- 2
df2$idtOK[grep("BBXX",df2$qcid)] <- FALSE
df2$idtype <- ifelse(is.na(df2$qcid),4,df2$idtype)

#print(table(df2$idtype))

 idtmp <- ifelse(!is.na(df2$id),df2$id,"")
 df2$idtOK <- ifelse(idtmp %in% ship.names, TRUE, df2$idtOK)
 df2$idtOK <- ifelse(df2$qcid %in% form_generic, FALSE, df2$idtOK)

if (sum(is.na(df2$idtype)) > 0 ) {
  print('got idtype values not set')
  print(table(df2$dck,!is.na(df2$idtype)))
}

return(df2)

}
