local util = import '_util.libsonnet';
{
    availability(param):: {
     local slo = {
       metric: error 'must set metric for errors',
       selectors: [],
       nonErrorSelectors: ['code!~"5.."'],
       rate: '5m',
       labels: [],
      } + param,
    
    local labels = 
      util.selectorsToLabels(slo.selectors) + 
      util.selectorsToLabels(slo.labels),
    recordingrule: {
        expr: |||
          sum(rate(%(metric)s{%(nonErrorSelectors)s}[%(rate)s]))
          /
          sum(rate(%(metric)s{%(selectors)s}[%(rate)s]))
        ||| % {
          metric: slo.metric,
          selectors: std.join(',', slo.selectors),
          nonErrorSelectors: std.join(',', slo.selectors + slo.nonErrorSelectors),
          rate: slo.rate
        },
        record: '%(metric)s:availability%(rate)s' % {
            metric: slo.metric,
            rate:slo.rate
        },
        labels: labels,
      }
    }
}