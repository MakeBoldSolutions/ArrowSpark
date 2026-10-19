import { chromium, firefox } from 'playwright';
import { mkdir, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const url = process.argv[2] ?? 'http://localhost:4321/play/';
const output = resolve(process.argv[3] ?? '../artifacts/portrait-play');
await mkdir(output, { recursive: true });
const engine = process.argv.includes('--firefox') ? firefox : chromium;
const browser = await engine.launch({ headless: true, ...(process.argv.includes("--chrome") ? { channel: "chrome" } : {}) });
const results = [];
try {
  for (const [width, height, dpr, touch] of [[360,640,1,true],[390,844,1,true],[412,915,1,true],[360,640,3,true],[390,844,3,true],[412,915,3,true],[640,320,1,true],[915,412,1,true],[1280,720,1,false],[1920,1080,1,false]]) {
    const context = await browser.newContext({ viewport: {width,height}, deviceScaleFactor: dpr, hasTouch: touch });
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', e => errors.push(String(e)));
    await page.goto(url);
    await page.waitForFunction(() => document.documentElement.dataset.play === 'play');
    const frame = page.frameLocator('iframe[data-game-frame]');
    await frame.locator('body[data-engine-state="started"]').waitFor({state:"attached",timeout:60000});
    await page.locator('[data-game-host]').scrollIntoViewIfNeeded();
    await page.waitForTimeout(3000);
    const measure = await page.evaluate(() => {
      const host = document.querySelector('[data-game-host]');
      const stage = document.querySelector('.game-frame__stage');
      const rect = host.getBoundingClientRect();
      const style = getComputedStyle(stage);
      return { host: {width:rect.width,height:rect.height}, overflow:document.documentElement.scrollWidth > innerWidth, touchAction:style.touchAction, overscroll:style.overscrollBehavior, src:document.querySelector('iframe[data-game-frame]').getAttribute('src') };
    });
    if (measure.overflow || (touch && measure.host.height > height + 1) || errors.length) throw new Error(JSON.stringify({width,height,measure,errors}));
    await page.screenshot({ path:resolve(output,`${width}x${height}-dpr${dpr}.png`) });
    const original = await page.locator('iframe[data-game-frame]').elementHandle();
    await page.setViewportSize({width:height,height:width});
    await page.waitForTimeout(250);
    await page.setViewportSize({width,height});
    await page.waitForTimeout(250);
    if (!await original.evaluate(node => node === document.querySelector('iframe[data-game-frame]'))) throw new Error('iframe replaced');
    if (await page.locator('iframe[data-game-frame]').getAttribute('src') !== measure.src) throw new Error('iframe source changed');
    results.push({width,height,dpr,touch,...measure,errors});
    await context.close();
  }
  await writeFile(resolve(output,'host-results.json'),JSON.stringify({browser:browser.version(),results},null,2));
  console.log(`PASS: ${results.length} real-export host fixtures; device gestures and canvas geometry require separate evidence.`);
} finally { await browser.close(); }
