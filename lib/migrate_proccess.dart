List mtn = ['04', '05', '06', '44', '45', '46', '54', '55', '56', '64', '65', '66', '74', '75', '76', '84', '85', '86', '94',
  '95', '96'];
List moov = ['01', '02', '03', '40', '41', '42', '43', '50', '51', '52', '53', '70', '71', '72', '73'];
List orange = ['07', '08', '09', '47', '48', '49', '57', '58', '59', '67', '68', '69', '77', '78', '79', '87', '88', '89',
  '97', '98'];

List mtnFixe = ['200', '210', '220', '230', '240', '300', '310', '320', '330', '340', '350', '360'];
List moovFixe = ['208', '218', '228', '238'];
List orangeFixe = ['202', '203', '212', '213', '215', '217', '224', '225', '234', '235', '243', '244', '245', '306', '316',
  '319', '327', '337', '347', '359', '368'];

List newPrefix = ['05','25','01','21','07','27'];

// Allow to delete the newer prefix
String prefixDeleter(String num, int long){

  if (long == 14) {
    var prefixCountry = num.substring(0,4);
    if(prefixCountry == "+225"){
      num = num.substring(6, num.length);
    }
  }

  else if (long == 13) {
    var prefixCountry = num.substring(0,3);
    if(prefixCountry == "225"){
      num = num.substring(5, num.length);
    }
  }

  else if (long == 10) {
    num = num.substring(2, num.length);
  }

  return num;
}

// Add new prefix to the number, it's the second part of prefixator
String prefixAdder(String prefix, String prefixFi, String num, String pat) {
  if (mtn.contains(prefix)) {
    num = num.replaceAll(pat, pat + "05"); //pat == pattern
  }
  else if (mtnFixe.contains(prefixFi)) {
    num = num.replaceAll(pat, pat + "25");
  }

  if (moov.contains(prefix)) {
    num = num.replaceAll(pat, pat + "01");
  }
  else if (moovFixe.contains(prefixFi)) {
    num = num.replaceAll(pat, pat + "21");
  }

  if (orange.contains(prefix)) {
    num = num.replaceAll(pat, pat + "07");
  }
  else if (orangeFixe.contains(prefixFi)) {
    num = num.replaceAll(pat, pat + "27");
  }

  return num;
}

// Extract prefix of the number and call prefixator to get final number
String prefixator(String num, int long) {
  var numFinal = num;
  var prefix;
  var prefixFi;

  if (long == 12) {
    prefix = num[4] + num[5];
    prefixFi = num[4] + num[5] + num[6];
    numFinal = prefixAdder(prefix, prefixFi, num, "+225");
  }

  else if (long == 11) {
    prefix = num[3] + num[4];
    prefixFi = num[3] + num[4] + num[5];
    num = "+225" + num.substring(3, num.length);
    numFinal = prefixAdder(prefix, prefixFi, num, "+225");
  }

  else if (long == 8) {
    prefix = num.substring(0, 2);
    prefixFi = num.substring(0, 3);
    num = " " + num;
    numFinal = prefixAdder(prefix, prefixFi, num, " ");
  }

  return numFinal;
}

// Format number and call prefixator to have final number
String migration(String x) {

  var numInit = x.replaceAll("-", "").replaceAll(" ", "")
      .replaceAll("(", "")
      .replaceAll(")", "");

  var numOk = x;

  if ((numInit.length) == 12) {
    if (numInit.substring(0, 4) == "+225") { // [:4]
      numOk = prefixator(numInit, 12);
    }
  }

  else if ((numInit.length) == 11) {
    if (numInit.substring(0, 3) == "225") { //[:3]
      numOk = prefixator(numInit, 11);
    }
  }

  else if((numInit.length) == 13){
    if (numInit.substring(0, 5) == "00225") {
      numInit = "+225" + numInit.substring(5, numInit.length);
      numOk = prefixator(numInit, 12);
    }
  }

  else if ((numInit.length) == 8) {
    numOk = prefixator(numInit, 8);
  }

  return numOk;
}