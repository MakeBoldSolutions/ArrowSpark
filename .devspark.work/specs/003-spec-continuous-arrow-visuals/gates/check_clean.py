import os, subprocess, tempfile, shutil
from pathlib import Path
engine=Path('.devspark.work/specs/003-spec-continuous-arrow-visuals/gates/godot44-path.txt').read_text(encoding='utf-8')
evidence=Path('.devspark.work/specs/003-spec-continuous-arrow-visuals/gates')
with tempfile.TemporaryDirectory(prefix='arrow44-clean-') as d:
 root=Path(d)/'project'; root.mkdir()
 for name in ['addons','assets','resources','scripts','scenes','tests']:
  shutil.copytree(name,root/name,ignore=shutil.ignore_patterns('__pycache__'))
 for source in Path('.').iterdir():
  if source.is_file() and source.suffix in ['.godot','.tres','.png','.svg','.import']:
   shutil.copy2(source,root/source.name)
 env=dict(os.environ,APPDATA=str(Path(d)/'data'),XDG_DATA_HOME=str(Path(d)/'data'))
 result=subprocess.run(['python',str(root/'tests/run_puzzle_regressions.py'),'--godot',engine],env=env,capture_output=True,text=True,timeout=180)
 (evidence/'godot44-clean-import-wait.log').write_text(result.stdout+result.stderr,encoding='utf-8')
 print(result.returncode,[l for l in result.stdout.splitlines() if 'FAILURES=' in l])
 if result.returncode: print(result.stdout[-1500:]+result.stderr[-1200:])
