Dưới đây là nội dung của bảng **PaperTrend Analysis** được chuyển sang định dạng Markdown:


| No | Name                          | Fact Table        | Dimension Table                         | Description                                   | Display Type          |
| :- | :---------------------------- | :---------------- | :-------------------------------------- | :-------------------------------------------- | :-------------------- |
| 1  | Publication Trend             | Paper             | Time                                    | Số lượng bài báo theo năm                     | Line Chart            |
| 2  | Citation Trend                | Paper             | Time                                    | Tổng citation theo năm                        | Line Chart            |
| 3  | Top Keywords                  | PaperKeyword      | Keyword                                 | Keyword xuất hiện nhiều nhất                  | Horizontal Bar        |
| 4  | Emerging Keywords             | PaperKeyword      | Keyword, Time                           | Keyword tăng trưởng nhanh nhất                | Line Chart            |
| 5  | Topic Evolution               | PaperKeyword      | Topic, Time                             | Sự thay đổi của Topic theo thời gian          | Area Chart            |
| 6  | Research Landscape            | PaperKeyword      | Domain, Field, Topic                    | Phân bố nghiên cứu theo các lĩnh vực          | Treemap               |
| 7  | Top Authors                   | PaperAuthor       | Author                                  | Tác giả có nhiều công bố nhất                 | Horizontal Bar        |
| 8  | Author Impact                 | PaperAuthor       | Author                                  | Tác giả có citation cao nhất                  | Scatter Plot          |
| 9  | Author Productivity vs Impact | PaperAuthor       | Author                                  | So sánh Productivity và Citation              | Scatter Plot          |
| 10 | Institution Ranking           | AuthorInstitution | Institution                             |                                               | Horizontal Bar        |
| 11 | Institution Impact            | AuthorInstitution | Institution                             | Quan hệ hợp tác giữa tổ chức                  | Bubble Chart          |
| 12 | Country Research Output       | Paper             | Country                                 | Số lượng bài báo theo quốc gia                | Map                   |
| 13 | Country Citation Impact       | Paper             | Country                                 | Citation theo quốc gia                        | Map                   |
| 14 | Journal Ranking               | Paper             | Journal                                 | Journal có nhiều bài báo nhất                 | Horizontal Bar        |
| 15 | Journal Impact Analysis       | Paper             | Journal                                 | Citation vs SJR vs H-index                    | Scatter Plot          |
| 16 | Quartile Distribution         | Paper             | Journal                                 | Phân bố Q1-Q4                                 | Donut Chart           |
| 17 | Citation Network              | Citation          | Paper                                   | Quan hệ trích dẫn giữa các bài báo            | Network Graph         |
| 18 | Author Collaboration          | PaperAuthor       | Author                                  | Quan hệ đồng tác giả                          | Network Graph         |
| 19 | Institution Collaboration     | AuthorInstitution | Institution                             |                                               | Network Graph         |
| 20 | Country Collaboration         | AuthorInstitution | Country                                 | Quan hệ hợp tác giữa quốc gia                 | Scatter Plot          |
| 21 | Keyword Co-occurrence         | PaperKeyword      | Keyword                                 | Các keyword thường xuất hiện cùng nhau        | Network Graph         |
| 22 | Topic Co-occurrence           | PaperKeyword      | Topic                                   | Quan hệ giữa các topic nghiên cứu             | Network Graph         |
| 23 | Journal-Topic Matrix          | Paper             | Journal, Topic                          | Journal nào mạnh ở Topic nào                  | Heatmap               |
| 24 | Author-Topic Matrix           | PaperAuthor       | Author, Topic                           | Chuyên môn nghiên cứu của tác giả             | Heatmap               |
| 25 | Institution-Topic Matrix      | AuthorInstitution | Institution, Topic                      | Thế mạnh nghiên cứu của tổ chức               | Heatmap               |
| 26 | Country-Topic Matrix          | Paper             | Country, Topic                          | Chủ đề nghiên cứu theo quốc gia               | Heatmap               |
| 27 | Research Frontier Detection   | PaperKeyword      | Keyword, Time                           | Phát hiện chủ đề mới nổi                      | Bubble Chart          |
| 28 | Citation Velocity             | Paper             | Time, Keyword                           | Tốc độ tăng citation của chủ đề               | Line Chart            |
| 29 | Journal Migration             | Paper             | Journal, Time                           | Xu hướng chuyển dịch công bố giữa các Journal | Sankey Diagram        |
| 30 | Research Ecosystem Overview   | Paper             | Time, Journal, Author, Keyword, Country | Tổng quan toàn bộ hệ sinh thái nghiên cứu     | Interactive Dashboard |
