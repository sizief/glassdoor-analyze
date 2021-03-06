## Glassdoor Software Job Analyze

The purpose of this script is crawl, save and analyze Glassdoor job postings and generate comparison charts for `languages` and `technologies` for multiple cities.  

If you want to check the final result, just checkout the [result](./result) folder.

To run it yourself, here is the instruction:


- Visit Glassdoor, search for any keyword and navigate to second page. Copy the url.
- Remove "last number" and ".htm" from the end of url.
- Open the [config](./config.yml) file and update the `url` section. There is a specefic format for URL section:
  which contains `CITY ; URL UNTIL NAME OF CITY ; REMAININGS OF URL WITHOUT THE KEYWORD YOU SEARCHED`. See the [Config file](./config.yml).
- `cd` to repo and run `./client.rb`. You need to have `Ruby` installed. It will save all IDs (for each job posting) and pages. And then it will generate reports and saves it to `result` folder. A `yml` file and `png` format. 
- In case you want to change the keywords or categories, just update the [config.yml](./config.yml).

Charts are generated using [Gruff](https://github.com/topfunky/gruff).

This is the chart for total ten cities aroud the world  
![languages](./result/total-languages.png)
  
![technologies](./result/total-technologies.png)
