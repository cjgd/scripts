#! /bin/awk -f

# gender-pt.awk -- guess gender (sex) from a portuguese Christian name
# Carlos Duarte <cgd@teleweb.pt>, 000607/070513

BEGIN {
	# table for latin1 conversion
	lat[sprintf("%c",192)]="A"; lat[sprintf("%c",193)]="A";
	lat[sprintf("%c",194)]="A"; lat[sprintf("%c",195)]="A";
	lat[sprintf("%c",199)]="C"; lat[sprintf("%c",200)]="E";
	lat[sprintf("%c",201)]="E"; lat[sprintf("%c",202)]="E";
	lat[sprintf("%c",204)]="I"; lat[sprintf("%c",205)]="I";
	lat[sprintf("%c",206)]="I"; lat[sprintf("%c",210)]="O";
	lat[sprintf("%c",211)]="O"; lat[sprintf("%c",212)]="O";
	lat[sprintf("%c",213)]="O"; lat[sprintf("%c",217)]="U";
	lat[sprintf("%c",218)]="U"; lat[sprintf("%c",219)]="U";
	lat[sprintf("%c",224)]="a"; lat[sprintf("%c",225)]="a";
	lat[sprintf("%c",226)]="a"; lat[sprintf("%c",227)]="a";
	lat[sprintf("%c",231)]="c"; lat[sprintf("%c",232)]="e";
	lat[sprintf("%c",233)]="e"; lat[sprintf("%c",234)]="e";
	lat[sprintf("%c",236)]="i"; lat[sprintf("%c",237)]="i";
	lat[sprintf("%c",238)]="i"; lat[sprintf("%c",242)]="o";
	lat[sprintf("%c",243)]="o"; lat[sprintf("%c",244)]="o";
	lat[sprintf("%c",245)]="o"; lat[sprintf("%c",249)]="u";
	lat[sprintf("%c",250)]="u"; lat[sprintf("%c",251)]="u";

	# endings
	end["ia"] = "f"
	end["la"] = "f"
	end["na"] = "f"
	end["io"] = "m"
	end["lo"] = "m"
	end["des"] = "m"
	end["de"] = "f"
	end["a"] = "f"
	end["o"] = "m"
	end["l"] = "m"
	end["que"] = "m"
	end["ui"] = "m"
	end["se"] = "m"

	# full names 
	name["dinis"] = "m"
	name["alexandre"] = "m"
	name["alice"] = "f"
	name["benjamim"] = "m"
	name["david"] = "m"
	name["dulce"] = "f"
	name["elisabete"] = "f"
	name["filipe"] = "m"
	name["heitor"] = "m"
	name["helder"] = "m"
	name["iris"] = "f"
	name["joaquim"] = "m"
	name["jorge"] = "m"
	name["nelson"] = "m"
	name["vitor"] = "m"
	name["leonor"] = "f"
	name["herman"] = "m"
	name["ramon"] = "m"
	name["pierre"] = "m"
	name["edgar"] = "m"
	name["duarte"] = "m"
	name["valter"] = "m"
	name["ruben"] = "m"
	name["lawrence"] = "m"
	name["franklin"] = "m"
	name["allen"] = "m"
	name["cesar"] = "m"
	name["andre"] = "m"
	name["guilherme"] = "m"
	name["isabel"] = "f"
	name["monique"] = "f"
	name["raquel"] = "f"
}

function no_latin1(s, 	i, r, t, c) {
	for (i=1; i<=length(s); i++) {
		c = substr(s,i,1)
		t = lat[c]
		r = r "" (t ? t : c)
	}
	return r
}

{ x=""; orig_name = $1; my_name = tolower(no_latin1(orig_name)) }

# try the full name 
!x { x = name[my_name] }

# try endings
!x {
	for (i=4; i>=1; i--) {
		ending = substr(my_name, length(my_name)-i+1,i)
		x = end[ending]; 
		if (x) break; 
	}
}

# if have an "s" ending, remove-it, then try endings again 
# (carlos -> carlo -> end: lo -> male)
!x {
	if (substr(my_name,length(my_name),1)=="s") {
		for (i=4; i>=1; i--) {
			ending = substr(my_name, length(my_name)-i,i)
			x = end[ending]; 
			if (x) break; 
		}
	}
}

{ print orig_name, x?x:"\t\tcouldn't find!" }
