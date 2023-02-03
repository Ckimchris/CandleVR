using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;

public class CandleMelt : MonoBehaviour
{
    public SkinnedMeshRenderer candleStem;
    public GameObject fire;
    public GameObject startPoint;
    public GameObject endPoint;
    public TextMeshPro buttonText;
    public TextMeshProUGUI clockText;
    public float speed;

    private float maxDuration;
    private float timeRemaining = 1800f;
    private float minutes = 0;
    private float seconds = 0;
    private bool started;
    private IEnumerator coroutine;

    // Start is called before the first frame update
    void Start()
    {
        maxDuration = timeRemaining;
        SetFirePosition();
        minutes = Mathf.FloorToInt(timeRemaining / 60);
        seconds = Mathf.FloorToInt(timeRemaining % 60);
    }

    // Update is called once per frame
    void Update()
    {
        DisplayTime(timeRemaining);
    }

    public void ToggleButton()
    {
        if(started)
        {
            StopTimer();
            started = false;

            SetButtonText("Start");
        }
        else
        {
            StartTimer();
            started = true;

            SetButtonText("Stop");
        }
    }

    public void StartTimer()
    {
        coroutine = Melt();
        StartCoroutine(coroutine);

    }

    public void StopTimer()
    {
        LightFlame(false);
        StopCoroutine(coroutine);
    }

    void DisplayTime(float timeToDisplay)
    {
        if(timeToDisplay >= 0)
        {
            minutes = Mathf.FloorToInt(timeToDisplay / 60);
            seconds = Mathf.FloorToInt(timeToDisplay % 60);
            if (clockText != null)
            {
                clockText.text = string.Format("{0:00}:{1:00}", minutes, seconds);
            }
        }
    }

    void SetFirePosition()
    {
        //100 is the max blend weight value
        Vector3 startPos = Vector3.zero;
        Vector3 endPos = Vector3.zero;
        float candleBlendValue = 0;

        if (startPoint != null)
        {
            startPos = startPoint.transform.localPosition;
        }

        if (endPoint != null)
        {
            endPos = endPoint.transform.localPosition;
        }

        if(candleStem != null)
        {
            candleBlendValue = candleStem.GetBlendShapeWeight(0);
        }

        var value = (((startPos - endPos) / 100) * candleBlendValue);

        if(fire != null)
        {
            fire.transform.localPosition = new Vector3(value.x, (startPos.y - value.y), value.z);
        }
    }


    void LightFlame(bool isLit)
    {
        if(fire != null)
        {
            fire.gameObject.SetActive(isLit);
        }
    }

    public void SetTimer(float value)
    {
        if (candleStem != null)
        {
            //variable speed is the rate at which the candle values are adjusted
            var val = Mathf.Min(Mathf.Round((value * speed)), 100);

            var minuteIncrementValue = 60 / (maxDuration / 100);
            //In order to adjust the candle timer by 1 minutes increments, the blend shape weight value must be adjusted at a rate of val * the result of 60/18, which is 3.333333333333333f. The candle blend value will now move at a rate of 3.333333333333333f
            candleStem.SetBlendShapeWeight(0, Mathf.Min(val * minuteIncrementValue, 100));

            //1800 represents the float value equivalent of 30 minutes. 18 * the blend shape weight is the value to convert the current blend value into time
            timeRemaining = maxDuration - ((maxDuration / 100) * candleStem.GetBlendShapeWeight(0));
            SetFirePosition();
        }
    }

    void SetButtonText(string text)
    {
        if (buttonText != null)
        {
            buttonText.text = text;
        }
    }

    public IEnumerator Melt()
    {
        if(fire != null && candleStem != null)
        {
            SetFirePosition();
            LightFlame(true);
            float time = 0;
            float startValue = candleStem.GetBlendShapeWeight(0);
            //100 is the max blend weight value
            float endValue = 100;
            float duration = timeRemaining;
            float endHeight = 0;

            float startHeight = fire.transform.localPosition.y;

            if (endPoint != null)
            {
                endHeight = endPoint.transform.localPosition.y;
            }

            while (time <= duration)
            {
                candleStem.SetBlendShapeWeight(0, Mathf.Lerp(startValue, endValue, time / duration));
                fire.transform.localPosition = new Vector3(0, Mathf.Lerp(startHeight, endHeight, time / duration), 0f);

                time += Time.deltaTime;
                timeRemaining -= Time.deltaTime;
                DisplayTime(timeRemaining);
                yield return null;
            }
            fire.transform.localPosition = new Vector3(0, endHeight, 0);

            candleStem.SetBlendShapeWeight(0, endValue);
            DisplayTime(0);
            LightFlame(false);
            started = false;

            SetButtonText("Start");

            yield return null;
        }
    }
}
