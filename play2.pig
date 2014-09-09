
-- {
-- 	person: {name: John, desc: [d1,d2], cls: [c1,c2]}, 
-- 	wiki: [url1,url2], 
-- 	lvd: [
-- 		{name: place1, desc: [d1,d2], cls:[c1,c2]},
-- 		{name: place2, desc: [d1,d2], cls:[c1,c2]},
-- 	]
-- }
data = load 'tojoin' using PigStorage() as (l, p, r);
des = filter data by p == 'desc';
wik = filter data by p == 'wiki';
cls = filter data by p == 'class';
lvd = filter data by p == 'lived';

dest = foreach des generate l as id, r as ds;
wikt = foreach wik generate l as id, r as wk;
clst = foreach cls generate l as id, r as cl;
lvdt = foreach lvd generate l as id, r as pl;
pplt = foreach lvd generate l as id;
pplt = distinct pplt;

desg = group dest by id;
wikg = group wikt by id;
clsg = group clst by id;

lvdj = join lvdt by pl, desg by group, clsg by group;
lvdj = foreach lvdj generate
		lvdt::id as id,
		lvdt::pl as plc,
		desg::dest.ds as des,
		clsg::clst.cl as cls;

lvdjg = group lvdj by id;
-- dump lvdjg;

perj = join pplt by id, desg by group, clsg by group;
perj = foreach perj generate
		pplt::id as psn,
		desg::dest.ds as des,
		clsg::clst.cl as cls;

allj = join perj by psn, wikg by group,lvdjg by group;

final = foreach allj generate 
			perj::psn as person_id,
			perj::des as person_desc,
			perj::cls as person_cls,
			wikg::wikt.wk as wiki,
			lvdjg::lvdj as places;

store final into 'out2.json' using JsonStorage();