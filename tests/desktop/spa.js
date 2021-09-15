module.exports = async function(context, commands) {
  commands.meta.setTitle('Test Grafana SPA');
  commands.meta.setDescription(
    'Test the first page, click the timepicker and then choose <b>Last 30 days</b> and measure that page.'
  );
  await commands.measure.start(
    'https://dashboard.sitespeed.io/d/000000064/drilldown?orgId=1',
    'pageTimingMetricsDefault'
  );
  await commands.click.byClassName('toolbar-button css-bdxldk-toolbar-button');
  await commands.wait.byTime(3000);
  await commands.measure.start('pageTimingMetrics30Days');
  try {
    await commands.click.byXpathAndWait(
      '/html/body/div/div/main/div[3]/header/div/div[4]/div/div[1]/div/div/div/div[1]/div[1]/section[1]/fieldset/ul/li[11]'
    );
    await commands.wait.byTime(5000);
  } catch (e) {
    context.log.error('Could not find Grafanas 30 days dropdown');
    throw e;
  }

  return commands.measure.stop();
};
