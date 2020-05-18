module.exports = async function(context, commands) {
  commands.meta.setTitle('Test Grafana SPA');
  commands.meta.setDescription(
    'Test the first page, click the timepicker and then choose <b>Last 30 days</b> and measure that page.'
  );
  await commands.measure.start(
    'https://dashboard.sitespeed.io/d/000000059/page-timing-metrics?orgId=1',
    'pageTimingMetricsDefault'
  );
  await commands.click.byClassName('btn navbar-button navbar-button--tight');
  await commands.wait.byTime(1000);
  await commands.measure.start('pageTimingMetrics30Days');
  await commands.click.byXpathAndWait(
    '/html/body/grafana-app/div/div/react-container/div/div[1]/div[6]/div/div[1]/div/div/div/div[2]/div[1]/div[2]/div[11]/span'
  );
  await commands.measure.stop();
};
