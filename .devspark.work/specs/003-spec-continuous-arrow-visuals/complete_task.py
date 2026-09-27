from pathlib import Path
import re,sys
p=Path(__file__).parent
if __name__=='__main__':
    task,code,knowledge=sys.argv[1:4]
    file=p/'tasks.md'; s=file.read_text(encoding='utf-8')
    s=re.sub(r'^- \[ \] '+task+r'\b.*$',lambda m:m[0].replace('- [ ]','- [X]',1).replace('code_ref: pending | knowledge_ref: pending',f'code_ref: {code} | knowledge_ref: {knowledge}'),s,flags=re.M)
    file.write_text(s,encoding='utf-8')
