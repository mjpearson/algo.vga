program WriteGDat;

type
    Goffy = record
      Code : string[2];
      Header : string[35];
      trailer : string[60];
    end;

const
 gcprofession : array [1..45,1..3] of string = (

  ('Au','Authorship',''),
  ('AS','Applied Sciences',' (Nursing, Librarianship, etc.)'),
  ('Bi','Biology',''),
  ('Bu','Business/Accountancy',''),
  ('GD','Commercial Arts/Graphic Design',''),
  ('CS','Computer Science',''),
  ('CD','Clothing Design/Production',''),
  ('DJ','DJ`ing, (music programming)',''),
  ('En','Engineering',''),
  ('Fa','Farming',''),
  ('FA','Fine Arts',''),
  ('Go','Government',''),
  ('HS','High School',' (use only if you`re still there)'),
  ('Hu','Humanities',''),
  ('Ju','Jurisprudence (Law)',''),
  ('Ma','Math',''),
  ('MA','Manual Arts',' (woodwork, metalwork, leatherwork, etc)'),
  ('MD','Medicine',''),
  ('Mu','Music',' (writing, producing, _not_ DJ`ing)'),
  ('NA','Massage, herbal lore, `new age remedies,` etc.',''),
  ('Ph','Philosophy',''),
  ('SB','Small Business',''),
  ('Im','Photography and Image Creation',''),
  ('PS','the Physical Sciences',' (Physics, Chemistry, Biology etc)'),
  ('Sa','Sales Oriented Stuff',' (burger flipping, telemarketting, etc)'),
  ('Sb','the Sex Industry: BDSM-related',''),
  ('Sp','the Sex Industry: Production of related goods',''),
  ('SS','Social Science',' (Psychology, Sociology, etc.)'),
  ('Th','Theater',' (it`s so goth to be "GoTh" ;-))'),
  ('Tr','the Trades',' (electricians, plumbing, carpentry, etc)'),
  ('TW','Technical Writing',''),
  ('ZZ','Other.','  Some goths do unusual things for a living..'),
  ('??','Undecided.',' Those who might be changing vocations/lost their memory'),
  ('AT','All Trades.',' For those gothics that can do anything and everything.'),
  ('NQ','No Qualifications.',''),
  ('10','I am recognised universally as the eminent person in my field',''),
  (' 9','Postdoctoral degree, such as a DLitt, etc.',''),
  (' 8','Over qualified to work any job with a Ph.D.',''),
  (' 7','Honours or a Masters degree grad.',''),
  (' 6','Managed to finish my bachelors/postgrad diploma or apprenticeship.',''),
  (' 5','Learned it the hard way and I`m now an expert...',''),
  (' 4','Finished a short-course (2 years or less)',''),
  (' 3','Started a degree or short course, and plan to finish it some day.',''),
  (' 2','Learned it the hard way and now planning my future in this field',''),
  (' 1','I`m a half-wit when it comes to this.',''));

var
   Gothique : Goffy;
   CurrBuffer : array [1..40] of Goffy;
   f : file of Goffy;


var i : byte;

begin
  assign(f,'gofdat');
  rewrite(F);
  for i := 1 to 45 do
    begin
      Fillchar(Gothique.Code,sizeof(Gothique.Code),0);
      Fillchar(Gothique.Header,sizeof(Gothique.Header),0);
      Fillchar(Gothique.Trailer,sizeof(Gothique.Trailer),0);

      Gothique.Code:=gcprofession[i,1];
      Gothique.Header:=gcprofession[i,2];
      Gothique.Trailer:=gcprofession[i,3];
      write(f,Gothique);
    end;
  close(f);
end.