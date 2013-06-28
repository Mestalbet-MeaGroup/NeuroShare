function websites(mode)

switch(mode)

 case 'mailgruen'
  web('mailto:gruen@hbf.huji.ac.il');

 case 'maildiesmann'
  web('mailto:diesmann@biologie.uni-freiburg.de');

 case 'home'
  web('http://www.brainworks.uni-freiburg.de');

 otherwise
  error('WebSites::UnknownLocation');
end  

uiwait(findobj('Tag','SplashScreen'));