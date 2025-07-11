function session = get_logs(SUB)

DIR = get_dir(SUB);

session = struct();
for s = 1:4

    logFiles = dir(fullfile(DIR.behavDir{s},'*main-*.mat'));
    
    for r = 1:4
        session(s).logs(r) = load(fullfile(DIR.behavDir{s},logFiles(r).name));
        
    end 
end