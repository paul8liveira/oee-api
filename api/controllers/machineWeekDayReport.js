module.exports = function (api) {
  const _machineWeekDayReport = api.models.machineWeekDayReport;

  this.table = function (req, res) {
    const { channelId, machineCode, yearNumber, weekNumber, dateIni, dateEnd } = req.query;

    _machineWeekDayReport.table(
      { channelId, machineCode, yearNumber, weekNumber, dateIni, dateEnd },
      function (exception, result) {
        if (exception) {
          return res.status(400).send(exception);
        }
        const [data] = result;
        res.status(200).send(data);
      }
    );
  };

  this.chart = function (req, res) {
    const { channelId, machineCode, yearNumber, weekNumber, dateIni, dateEnd } = req.query;

    _machineWeekDayReport.chart(
      { channelId, machineCode, yearNumber, weekNumber, dateIni, dateEnd },
      function (exception, result) {
        if (exception) {
          return res.status(400).send(exception);
        }
        const [data] = result;
        res.status(200).send(data);
      }
    );
  };  

  return this;
};
