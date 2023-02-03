using System.Collections.Generic;
using UnityEngine;
using System;

namespace Oculus.Interaction
{
    public class CandleBlend : MonoBehaviour, ITransformer
    {
        public SkinnedMeshRenderer candleStem;
        public CandleMelt candleMelt;

        [Serializable]
        public class OneGrabTranslateConstraints
        {
            public bool ConstraintsAreRelative;
            public FloatConstraint MinY;
            public FloatConstraint MaxY;
        }

        [SerializeField]
        private OneGrabTranslateConstraints _constraints =
            new OneGrabTranslateConstraints()
            {
                MinY = new FloatConstraint(),
                MaxY = new FloatConstraint(),
            };

        public OneGrabTranslateConstraints Constraints
        {
            get
            {
                return _constraints;
            }

            set
            {
                _constraints = value;
                GenerateParentConstraints();
            }
        }

        private OneGrabTranslateConstraints _parentConstraints = null;
        private Vector3 _initialPosition;
        private Vector3 _grabOffsetInLocalSpace;
        private float _initialValue;
        private float lastValue;
        private IGrabbable _grabbable;

        public void Initialize(IGrabbable grabbable)
        {
            _grabbable = grabbable;
            _initialPosition = _grabbable.Transform.localPosition;
            if(candleStem != null)
            {
                _initialValue = candleStem.GetBlendShapeWeight(0);
            }
            GenerateParentConstraints();
        }

        private void GenerateParentConstraints()
        {
            if (!_constraints.ConstraintsAreRelative)
            {
                _parentConstraints = _constraints;
            }
            else
            {
                _parentConstraints = new OneGrabTranslateConstraints();

                _parentConstraints.MinY = new FloatConstraint();
                _parentConstraints.MaxY = new FloatConstraint();

                if (_constraints.MinY.Constrain)
                {
                    _parentConstraints.MinY.Constrain = true;
                    _parentConstraints.MinY.Value = _constraints.MinY.Value + _initialValue;
                }
                if (_constraints.MaxY.Constrain)
                {
                    _parentConstraints.MaxY.Constrain = true;
                    _parentConstraints.MaxY.Value = _constraints.MaxY.Value + _initialValue;
                }
            }
        }

        public void BeginTransform()
        {
            var grabPoint = _grabbable.GrabPoints[0];
            Transform targetTransform = _grabbable.Transform;
        }

        public void UpdateTransform()
        {
            var grabPoint = _grabbable.GrabPoints[0];
            var targetTransform = _grabbable.Transform;
            var constrainedPosition = (1 - grabPoint.position.y);

            if (_parentConstraints.MinY.Constrain)
            {
                constrainedPosition = Mathf.Max(constrainedPosition, _parentConstraints.MinY.Value);

            }

            if(candleMelt != null)
            {
                candleMelt.SetTimer(constrainedPosition);
            }

        }

        public void EndTransform() { }

        #region Inject

        public void InjectOptionalConstraints(OneGrabTranslateConstraints constraints)
        {
            _constraints = constraints;
        }

        #endregion
    }
}

