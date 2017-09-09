function s=osuFileRead(osufilename)


fg=fopen(osufilename,'r');
version=fgetl(fg);
version=regexp(version,'\d+','match');
version=version{1};
version=str2double(version);
str=fscanf(fg,'%c');
str=regexprep(str,'[ ]*:[ ]*',':');
str=regexprep(str,'"','');
str=regexprep(str,'//[\S ]*\r\n','');
str=regexprep(str,'(?<=[a-zA-Z]):(?=[\S\r])','":"');
str=regexprep(str,'(?<=Combo\d):(?=[\S\r])','":"');
str=regexprep(str,'\r\n','",\r\n"');
str=regexprep(str,'(?<!\r)\n','",\n"');
% % return
str=regexprep(str,'\[','');
str=regexprep(str,'(?<=(General|Editor|Metadata|Difficulty|Events|TimingPoints|Colours|HitObjects))\]",','"\:{');
str=regexprep(str,'"",','');
str=regexprep(str,',\r\n\r\n','},\r\n\r\n');
str=regexprep(str,':\r',':"",\r');
str=regexprep(str,'^",\r\n','');
str=regexprep(str,'"Events":{','"Events":[');
str=regexprep(str,'},(\r\n)*"TimingPoints":{','],\r\n\r\n"TimingPoints":[');
str=regexprep(str,'},(\r\n)*"Colours":{','],\r\n\r\n"Colours":{');
str=regexprep(str,'},(\r\n)*"HitObjects":{','],\r\n\r\n"HitObjects":[');
str=regexprep(str,',\r\n"$',']');
str=strcat('{',str,'}');
% outOsuFileName='out2.txt';
% outfg=fopen(outOsuFileName,'w');
% fprintf(outfg,'%s',str);
try
    s=jsondecode(str);
catch err
    
   str=regexprep(str,'],(\r\n)*"HitObjects":','},\r\n\r\n"HitObjects":');
   s=jsondecode(str);   
end
s.Version=version;
fclose(fg);
% fclose(outfg);

end