class SerachAndFilterOptions {
  static Map filterOptionSelection = {
    'sort_order': 'asc',
    'sortby': 'name',
    'type': 'funds',
  };

  static Map filterOptions = {
    'sortby': {
      'title': 'Sort By',
      'type': 'sort',
      'optionType': 'radio',
      'selectedOption': [null],
      'optionGroups': [
        {
          'key': 'scores',
          'group_title': 'Scores',
          'options': {
            'overall_rating': 'Overall Score',
            'tr_rating': 'Return Score',
            'alpha_rating': 'Alpha Score',
            'srri': 'Risk Score',
            'tracking_rating': 'Tracking Score'
          }
        },
        {
          'key': 'key_stats',
          'group_title': 'Key Stats',
          'options': {
            'cagr': '3 Year Return',
            'stddev': '3 Year Risks',
            'sharpe': 'Sharpe Ratio',
            'Bench_alpha': 'Alpha',
            'Bench_beta': 'Beta',
            'successratio': 'Success Rate',
            'inforatio': 'Information Ratio',
            'tna': 'AUM'
          }
        },
        {
          'key': 'name',
          'group_title': 'Name',
          'options': {'name': 'Name'}
        }
      ]
    },
    'zone': {
      'title': 'Country',
      'type': 'filter',
      'optionType': 'checkbox',
      'selectedOption': [null],
      'optionGroups': [
        {'group_title': '', 'options': {}},
      ]
    },
    'type': {
      'title': 'Type',
      'type': 'filter',
      'optionType': 'radio',
      'selectedOption': [null],
      'optionGroups': [
        {
          'group_title': '',
          'options': {
            'funds': 'Mutual Fund',
            'etf': 'ETF',
            'stocks': 'Stocks',
            'bonds': 'Bonds',
            'commodity': 'Commodity'
          }
        }, //
      ]
    },
    'share_class': {
      'title': 'Investment Share\nClass',
      'type': 'filter',
      'optionType': 'radio',
      'selectedOption': [null],
      'optionGroups': [
        {
          'group_title': '',
          'options': {'direct': 'Direct', 'regular': 'Regular'}
        },
      ]
    },
    'category': {
      'title': 'Category',
      'type': 'filter',
      'optionType': 'checkbox',
      'selectedOption': [null],
      'optionGroups': [
        {
          'group_title': '',
          'options': {
            'Balanced': 'Balanced',
            'MMF': 'MMF',
            'Mid Cap Equity': 'Mid Cap Equity',
            'Long Duration Debt': 'Long Duration Debt',
            'Large Cap Equity': 'Large Cap Equity',
            'Short Duration Debt': 'Short Duration Debt',
            'US Equity': 'US Equity',
            'Thematic': 'Thematic',
            'Small Cap Equity': 'Small Cap Equity'
          }
        },
      ]
    },
    'industry': {
      'title': 'Industry',
      'type': 'filter',
      'optionType': 'checkbox',
      'selectedOption': [null],
      'optionGroups': [
        {
          'group_title': '',
          'options': {
            'Industrials': 'Industrials',
            'Basic Materials': 'Basic Materials',
            'Utilities': 'Utilities',
            'Consumer Cyclicals': 'Consumer Cyclicals',
            'Financials': 'Financials',
            'Healthcare': 'Healthcare',
            'Consumer Non-Cyclicals': 'Consumer Non-Cyclicals',
            'Technology': 'Technology',
            'Energy': 'Energy',
            'Real Estate': 'Real Estate'
          }
        },
      ]
    },
    'overall_rating': {
      'title': 'Overall Score',
      'type': 'filter',
      'optionType': 'range_slider',
      'selectedOption': [null],
      'optionGroups': [
        {
          'key': 'overall_rating',
          'group_title': ' ',
          'options': {
            'range': {'title': 'Select Range', 'min': '1', 'max': '5'}
          }
        },
      ]
    },
    'key_stats': {
      'title': 'Key Stats',
      'type': 'filter',
      'optionType': 'range_slider',
      'selectedOption': [null],
      'optionGroups': [
        {
          'key': 'cagr',
          'group_title': ' ',
          'options': {
            'range': {'title': '3 Year Return', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'stddev',
          'group_title': '',
          'options': {
            'range': {'title': '3 Year Risks', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'sharpe',
          'group_title': '',
          'options': {
            'range': {'title': 'Sharpe Ratio', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'Bench_alpha',
          'group_title': '',
          'options': {
            'range': {'title': 'Alpha', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'Bench_beta',
          'group_title': '',
          'options': {
            'range': {'title': 'Beta', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'successratio',
          'group_title': '',
          'options': {
            'range': {'title': 'Success Rate', 'min': '1', 'max': '5'}
          }
        },
        {
          'key': 'inforatio',
          'group_title': '',
          'options': {
            'range': {'title': 'Information Ratio', 'min': '1', 'max': '5'}
          }
        },
        //{'key': '', 'group_title': '', 'options': {'range': {'min': '1', 'max': '5'}}},
      ]
    },
    /* 'aum_size':	{'title': 'AUM Size', 'type': 'filter', 'optionType': 'radio', 'selectedOption': [null],
			'optionGroups': [
				{'group_title': '', 'options': {'all': 'All', 't10': 'Top 10%', 't25': 'Top 25%', 't50': 'Top 50%', 'b25': 'Bottom 25%'}},
			]
		}, */
  };

  static Map categoryOptions = {
    'funds': {
      'Balanced': 'Balanced',
      'Cash/MMF': 'Cash/MMF',
      'Commodities': 'Commodities',
      'Debt DM': 'Debt DM',
      'Debt EM': 'Debt EM',
      'Debt Global': 'Debt Global',
      'Debt HY': 'Debt HY',
      'EM Equity': 'EM Equity',
      'Equity DM': 'Equity DM',
      'Equity EM': 'Equity EM',
      'Equity Global': 'Equity Global',
      'Equity SG': 'Equity SG',
      'Equity US': 'Equity US',
      'Europe Equity': 'Europe Equity',
      'Global Equity': 'Global Equity',
      'Large Cap Equity': 'Large Cap Equity',
      'Long Duration Debt': 'Long Duration Debt',
      'Mid Cap Equity': 'Mid Cap Equity',
      'MMF': 'MMF',
      'Short Duration Debt': 'Short Duration Debt',
      'Small Cap Equity': 'Small Cap Equity',
      'Thematic': 'Thematic',
      'US Equity': 'US Equity'
    },
    /* {'Balanced': 'Balanced', 'MMF': 'MMF', 'Mid Cap Equity': 'Mid Cap Equity', 'Long Duration Debt': 'Long Duration Debt', 'Large Cap Equity': 'Large Cap Equity', 'Short Duration Debt': 'Short Duration Debt', 'US Equity': 'US Equity', 'Thematic': 'Thematic', 'Small Cap Equity': 'Small Cap Equity'}, */
    'etf': {
      'Banking': 'Banking',
      'Cash/MMF': 'Cash/MMF',
      'Commodities': 'Commodities',
      'Debt DM': 'Debt DM',
      'Debt EM': 'Debt EM',
      'Debt Global': 'Debt Global',
      'Equity DM': 'Equity DM',
      'Equity EM': 'Equity EM',
      'Equity Global': 'Equity Global',
      'Global EM Equity': 'Global EM Equity',
      'Global Equity': 'Global Equity',
      'IT': 'IT',
      'Large Cap Equity': 'Large Cap Equity',
      'Mid Cap Equity': 'Mid Cap Equity',
      'MMF': 'MMF',
      'SG Equity': 'SG Equity',
      'Thematic': 'Thematic',
      'US Equity': 'US Equity'
    },
    /* {'Mid Cap Equity': 'Mid Cap Equity', 'Commodities': 'Commodities', 'Large Cap Equity': 'Large Cap Equity', 'MMF': 'MMF', 'Banking': 'Banking', 'Thematic': 'Thematic', 'IT': 'IT', 'US Equity': 'US Equity'}, */
    'stocks': {
      'Commercial REIT': 'Commercial REIT',
      'Equity EM': 'Equity EM',
      'Europe Equity': 'Europe Equity',
      'Large Cap Equity': 'Large Cap Equity',
      'Mid Cap Equity': 'Mid Cap Equity',
      'REIT': 'REIT',
      'SG Equity': 'SG Equity',
      'US Equity': 'US Equity'
    },
    /* {'Large Cap Equity': 'Large Cap Equity', 'Mid Cap Equity': 'Mid Cap Equity', 'REIT': 'REIT', 'Commercial REIT': 'Commercial REIT'}, */
    'bonds': {'Govt': 'Govt'},
  };
}