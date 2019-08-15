module.exports = async function(context, commands) {
  commands.meta.setTitle('Test Grafana SPA');
  commands.meta.setDescription(
    'Test the first page, click the timepicker and then choose <b>Last 30 days</b> and measure that page.'
  );
  await commands.measure.start(
    'https://dashboard.sitespeed.io/d/000000044/page-timing-metrics?orgId=1',
    'pageTimingMetricsDefault'
  );
  await commands.click.byClassName(
    'btn navbar-button navbar-button--tight time-picker-button-select'
  );
  await commands.wait.byTime(1000);
  await commands.measure.start('pageTimingMetrics30Days');
  await commands.click.byIdAndWait('react-select-2-option-11');
  await commands.measure.stop();
};
