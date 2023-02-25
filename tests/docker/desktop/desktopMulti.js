export default async function (context, commands) {
  commands.meta.setTitle('Test visiting multiple pages');
  commands.meta.setDescription(
    'First hit the Main_Page with an empty browser cache and then visit Barack, followed by the Democratic Party'
  );
  await commands.measure.start('https://en.wikipedia.org/wiki/Main_Page');
  // Fake some read time
  await commands.wait.byTime(21000);
  await commands.js.run(
    'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
  );
  await commands.measure.start('https://en.wikipedia.org/wiki/Barack_Obama');
  // Fake some read time
  await commands.wait.byTime(21000);
  await commands.js.run(
    'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
  );
  return commands.measure.start(
    'https://en.wikipedia.org/wiki/Democratic_Party_(United_States)'
  );
};
