export default async function (context, commands) {
  commands.meta.setTitle('Test multiple pages emulated mobile');
  commands.meta.setDescription(
    'First hit Main_Page with empty cache, then Barack and last Democratic Party.'
  );
  await commands.measure.start('https://en.m.wikipedia.org/wiki/Main_Page');
  await commands.js.run(
    'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
  );
  await commands.wait.byTime(300);
  await commands.measure.start('https://en.m.wikipedia.org/wiki/Barack_Obama');
  await commands.js.run(
    'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
  );
  await commands.wait.byTime(300);
  return commands.measure.start(
    'https://en.m.wikipedia.org/wiki/Democratic_Party_(United_States)'
  );
};
