module.exports = async function (context, commands) {
  commands.meta.setTitle('Test Grafana SPA');
  commands.meta.setDescription(
    'Test the first page, click the timepicker and then choose <b>Last 30 days</b> and measure that page.'
  );
  await commands.measure.start(
    'https://dashboard.sitespeed.io/d/9NDMzFfMk/page-metrics-desktop?orgId=1&var-base=sitespeed_io&var-path=desktop&var-testname=spa&var-group=dashboard_sitespeed_io&var-page=pageTimingMetricsDefault&var-browser=chrome&var-connectivity=cable&var-function=median&var-resulturl=https:%2F%2Fdata.sitespeed.io%2F&var-screenshottype=jpg',
    'pageTimingMetricsDefault'
  );
  await commands.click.byClassName('toolbar-button css-qo3whe-toolbar-button');
  await commands.wait.byTime(3000);
  await commands.measure.start('pageTimingMetrics30Days');
  try {
    await commands.click.byXpathAndWait(
      '/html/body/div[1]/div[1]/main/div[3]/header/nav/div[2]/div/div[1]/section/div/div[1]/div[1]/div[2]/div[1]/ul/li[11]'
    );
    await commands.wait.byTime(5000);
  } catch (e) {
    context.log.error('Could not find Grafanas 30 days dropdown');
    throw e;
  }

  return commands.measure.stop();
};
